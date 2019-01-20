require 'elasticsearch/persistence/model'

class Aditya::Aditya

	include Virtus.model
	include Elasticsearch::Persistence::Model
	include Concerns::EsConcern
	include Concerns::EsBulkIndexConcern

	INDEX_NAME = "manhis"
	DOC_TYPE = "history"

	
	def self.refresh_index(client)
		client.indices.refresh index: INDEX_NAME
	end

	def self.create_index(client)
			
		begin
			client.indices.delete index: Aditya::Aditya::INDEX_NAME
		rescue => e
			puts "index doesnt exist."
		end

		puts " -- creating index #{Aditya::Aditya::INDEX_NAME}"
	
		mappings = {
			Aditya::Aditya::DOC_TYPE.to_sym => {
				:dynamic => true,
				:properties => {
					:fdiag => {
						:type => 'keyword', 
						:fields => {
					        :raw => { 
					          	:type =>  'text', 
								:analyzer => "standard"
					        }
					    }
					}
				}
			}
		}

		
		resp = client.indices.create index: Aditya::Aditya::INDEX_NAME, body: {
			mappings: mappings
		}

		puts "index create response: #{resp}"

		resp

	end

	def self.populate_index(text_file_path="#{Rails.root}/vendor/aditya_index.txt")
		puts "populating index"
		index_dump = eval(IO.read(text_file_path))
		index_dump["hits"]["hits"].each do |hit|
			document = { index:  { _index: Aditya::Aditya::INDEX_NAME, _type: Aditya::Aditya::DOC_TYPE,  data: hit["_source"].as_json } }
			add_bulk_item(document)
		end
		flush_bulk
	end	

	def self.update_to_remote
		## will have to put the mappping first.
		## then we have to send the documents in bulk.
		create_index($remote_es_client)
		bulk_arr = []
		## will hav to scroll all.
		r = Elasticsearch::Persistence.client.search index: Aditya::Aditya::INDEX_NAME, scroll: '1m', body: {
			query: {
				match_all: {

				}
			}
		}

		initial_response = Hashie::Mash.new r

		initial_response.hits.hits.each do |hit|
			#puts "hit id is:"
			#puts hit._id.to_s
			#puts "hit source is:"
			#puts hit._source.to_s
			#puts hit._source.to_json
			#k = SaxObject.new(hit._source.to_hash)

			bulk_arr << {
				index: 
				{
					_index: Aditya::Aditya::INDEX_NAME, _id: hit._id, _type: Aditya::Aditya::DOC_TYPE, data: JSON.parse(hit._source.to_json)
				}
			}
		end

		while r = Elasticsearch::Persistence.client.scroll(body: { scroll_id: r['_scroll_id'] }, scroll: '5m') and not r['hits']['hits'].empty? do
			scroll_response = Hashie::Mash.new r
			scroll_response.hits.hits.each do |hit|
				bulk_arr << {
					index: {
						_index: Aditya::Aditya::INDEX_NAME, _id: hit._id, _type: Aditya::Aditya::DOC_TYPE, data: JSON.parse(hit._source.to_json)
					}
				}
				if bulk_arr.size > 500
					puts "bulking ----------------"
					response = $remote_es_client.bulk body: bulk_arr
					puts response.to_s
					bulk_arr.clear
				end
			end
        end
        $remote_es_client.bulk body: bulk_arr
	end

	####################################################################
	##
	##
	## PUBLIC METHOD -->
	##
	##
	####################################################################

	## Call this method to run whatever has to be run.
	## Don't touch the other methods.
	def self.main
		create_index
		populate_index
	end

end