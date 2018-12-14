require 'elasticsearch/persistence/model'

class Entity

	include Elasticsearch::Persistence::Model
	include Concerns::EsConcern
	include Concerns::EsBulkIndexConcern

	attribute :name, String,  mapping: { 
		type: 'keyword',
		fields: {
            raw: { 
              type:  'text'
            }
        } 
	}
		
	attribute :medical_type, String, mapping: {type: 'keyword'}
	
	attribute :textbook, String, mapping: {type: 'keyword'}

	attribute :subject, String, mapping: {type: 'keyword'}

	attribute :scores,Array[Hash], mapping: {
		type: "object",
		properties: {
			name: {
				type: "string"
			},
			score: {
				type: "float"
			}
		}
	}

	attribute :found_in_diseases, mapping: {type: 'keyword'}

	def self.score(array_of_terms,term_type)

		body = {
				"query" => {
					"match" => {
						"name.raw" => c
					}
				}
			}

		

		array_of_terms.map{|c|

			document_scores = {}

			r = Entity.gateway.client.search index: Entity.index_name, scroll: '1m', body: body
			
			initial_response = Hashie::Mash.new r

			initial_response.hits.hits.each do |hit|
				document_scores[hit.id.to_s] = hit.score.to_s
			end

			while r = client.scroll(body: { scroll_id: r['_scroll_id'] }, scroll: '5m') and not r['hits']['hits'].empty? do

				scroll_response = Hash::Mash.new r
				scroll_response.hits.hits.each do |hit|
					document_scores[hit.id.to_s] = hit.score.to_s
				end
             	
            end

            ## now you have these scores for these document ids.
            ## now make an update request and add it as bulk.
			
		}
	end

	def self.gather_found_in_diseases(name)
		p = Proc.new{|diagnosis_name,options|
			diagnosis_name			
		}
		paged_aggregation("Information","diagnosis_name",{term: {name: {value: name}}},nil,	p,{})
	end

end