require 'elasticsearch/persistence/model'

class SaxObject

	## we now move to update tests
	## like which field to search for workup?
	## and where to add it.
	## finally there are two main things.
	## title_text is relevant for doc only.
	## there the title must go.
	## for the others, it doesnt matter, but a field has to be tagged as workup.

	include Virtus.model
	## class variable to store topics
	
	## name of a function.

	attribute :process_with, String
	attribute :name, String
	attribute :content_text, String
	attribute :title_text, String


	## should be provided in the json file.
	attribute :textbook_name, String

	attr_accessor :textbook_file_path
	attr_accessor :topics
	attr_accessor :contains_tests
	attr_accessor :components
	attr_accessor :state
	## whether the field should be added to the searchable all field for 
	## the search query.
	attr_accessor :searchable
	## the important thing at this stage is to be able to put this into 
	## universal index.
	## by defining a mapping
	## into universal terms.
	## signs symptoms workup,
	## why not search content.raw for all?
	## only the workup should be common.
	## you can define one field as workup.
	## wherever the tests are .
	
	#######################################################################
	##
	##
	## TOPICS AND RELATED FUNCTIONS.
	##
	##
	#######################################################################

	TOPICS = []


	def exclusions
		["definition", "investigation", "treatment", "background", "classification", "epidemiology", "pathology", "pathophysiology", "management", "etiology", "symptoms", "signs", "etiopathogenesis", "differential", "diagnosis", "clinical", "features", "follow-up", "pathogenesis", "imaging", "mri", "etiologies", "incidence", "causes", "monitoring", "laboratory", "introduction", "part", "chapter", "investigations", "history", "assessment", "diagnostic", "procedures", "overview", "complications", "anatomy", "physiology", "indications", "contraindications", "terminology"]
	end

	##@return[Boolean] : true if the text provided should be excluded. 
	def exclude?(text)
		puts "text to exclude"
		puts text.to_s
		!exclusions.select{|c| text =~ /#{c}/i}.blank?		
	end

	## this is used to actually process the topic.
	## can be overriden if all that has to be changed is the regex.
	## here we can accept the text of the file as input, and return the topics
	## as an array as output
	## @return[Array] topics : the array of topics.
	## you are encouraged to override this method if required, so this should be the only method touched in any of the overriding classes.
	## lets test with the first oxford class.
	def add_topics(text)	
		[]
	end
	
	def get_topics
		
		if self.topics.blank?

			self.topics = []

			s = IO.read(textbook_file_path)
			
			s.force_encoding('UTF-8')
			
			s = s.encode('UTF-8', 'binary', invalid: :replace, undef: :replace, replace: '')

			self.topics = add_topics(s)

			self.topics = self.topics.flatten.map!{|c| c.gsub(/\d+/,'').strip}.reject{|c| c.blank?}.compact.uniq
			puts "total topics: #{self.topics.size}"
		end

		self.topics

	end

	###########################################################################


	SETTINGS = {
		index: { 
			number_of_shards: 1 
		}, 
		analysis: {
			filter: {
				nGram_filter: {
					type: "nGram",
					min_gram: 1,
					max_gram: 20,
					token_chars: [
						"letter",
						"digit",
						"punctuation",
						"symbol"
					]
				}
			},
			analyzer: {
				nGram_analyzer: {
					type: "custom",
					tokenizer: "whitespace",
					filter: [
						"lowercase",
						"asciifolding",
						"nGram_filter"
					]
				},
				whitespace_analyzer: {
					type: "custom",
					tokenizer: "whitespace",
					filter: [
						"lowercase",
						"asciifolding"
					]
				}
			}
		}
	}	 
	
	#######################################################################
	##
	##
	## MAPPINGS
	##
	##
	#######################################################################

	def build_index_mapping
		to_mapping
	end

	## if a particular item is searchable, then 
	## we can on calling to_mapping, set that mapping on it.
	def to_mapping
		mapping = nil
		######################### BASIC MAPPING ############################
		mapping = {
			self.name.to_sym => {
				:properties => {
		          	:content_text => {
						:type => 'text', 
						:analyzer => "standard",
						:search_analyzer => "whitespace_analyzer",
						:copy_to => []
					},
					:title_text => {
						:type => 'keyword', 
						:fields => {
					        :raw => { 
					          	:type =>  'text', 
								:analyzer => "standard",
								:search_analyzer => "whitespace_analyzer"
					        }
					    },
						:copy_to => []
					},
					:textbook_name => {
						:type => 'keyword', 
						:fields => {
					        :raw => { 
					          	:type =>  'text', 
								:analyzer => "standard",
								:search_analyzer => "whitespace_analyzer"
					        }
					    },
						:copy_to => []
					}
	          	}
          	}
		}
		#puts "mapping becomes first --------------:"
		#puts "commong field mapping ----"
		#puts COMMON_FIELD_MAPPING
		#puts JSON.pretty_generate(mapping) 

		######################## MERGE SEARCHABLE AT ROOT DOC ##############
		mapping[self.name.to_sym][:properties].merge!({
			:searchable => {
				:type => "text"
			},
			:workup_text => {
				:type => "text"
			},
			:workup => {
				:type => "keyword"
			}
		}) if self.name == "_doc"

		#puts "mapping becomes:"
		#puts JSON.pretty_generate(mapping)

		######################## COPY FIELD TO SEARCHABLE IF SEARCHABLE #####
		unless self.searchable.blank?
			#puts "this is the mapping"
			#puts mapping[self.name.to_sym][:properties][:content_text]
			mapping[self.name.to_sym][:properties][:content_text][:copy_to] << "searchable"
		end

		###################### IF CONTAINS_TESTS IS TRUE #####################
			
		unless self.contains_tests.blank?
			#puts "name is:#{self.name}, contains tests is: #{self.contains_tests}"
			if self.contains_tests == true
				mapping[self.name.to_sym][:properties][:content_text][:copy_to] << "workup_text"
			end
		end

		####################### SET FIELD TYPE AS NESTED UNLESS ITS ROOT DOC## 
		unless self.name == "_doc"
			mapping[self.name.to_sym].merge!(:type => "nested") 
		end


		###################### CALL PUT MAPPING ON ALL COMPONENTS ############
		self.components.each do |component|
			mapping[self.name.to_sym][:properties].merge!(component.to_mapping)
		end

		mapping

	end

	def get_index_name
		"documents-#{self.textbook_name.downcase.gsub(/\s/,'')}"
	end

	## deletes any existing index and recreates it with the defined mappings and settings.
	## @return[Boolean] true if the index was successfully created. 
	def delete_and_create_index(cli=Elasticsearch::Persistence.client)
		begin
			cli.indices.delete index: get_index_name
		rescue => e
			puts "index doesnt exist."
		end
		#if (Elasticsearch::Persistence.client.indices.exists? index: get_index_name)
			
		#end
		cli.indices.create index: get_index_name, body: {
			settings: SaxObject::SETTINGS,
			mappings: to_mapping
		}
	end
	##########################################################################
	##
	##
	## CONSTRUCTORS
	##
	##
	##########################################################################

	def initialize(args={})
		super(args)
		self.content_text ||= ""
		self.title_text ||= ""
		unless self.components.blank?
			self.components.map! {|component|
				if component.is_a? Hash
					component = self.class.new(component)
				else
					component
				end
			}
		end
	end

	#########################################################################
	##
	##
	## CALLED FROM SAX_PARSER ON EACH LINE
	##
	##
	#########################################################################

	def switch_off(except)
		unless self.name == except
			#puts "switching off : #{self.name}"
			self.state = "off"
		end
		self.components.each do |c|
			c.switch_off(except)
		end
	end

	def satisfies_condition?(line)
		response = self.send(self.process_with,line)
		#puts "line is: #{line} self name is: #{self.name}, response 0 is: #{response[0]}"
		if response[0] == "on"
			#puts "going to switch off, except #{self.name}"
			self.state = "on"
			SaxParser.switch_off(self.name)
			if self.name == "_doc"
				commit
				self.state = "on"
			end
		elsif response[0] == "off"
			self.components.each do |component|
				component.satisfies_condition?(line)
			end
		end 
		add_line(response[1])
	end

	def add_line(response_text)
		if self.state == "on"
			## is the self _doc ?
			## in that case, if anything was already there, it should be committed.
			## all the children should be cleared.
			unless response_text.blank?
				if self.name == "_doc"
					if self.title_text.blank?
						self.title_text = response_text
					else
						## here we have to add the first line from the content into the title.
						self.content_text += " " + response_text
					end
				else
					self.content_text += " " + response_text
				end
			end
		end
	end

	####################################################################
	##
	##
	## COMMIT AND ALLIED 
	##
	##
	####################################################################
	def commit

		if self.has_content?
			puts "called commit-----------#{self.title_text}"
			document = { index:  { _index: get_index_name, _type: '_doc',  data: self.as_json } }
			SaxParser::add_bulk_item(document)
			reset
		else
			puts self.attributes.to_s
			puts self.to_json.to_s
			puts "didnt commit, because content text is blank"
		end
	end


	def has_content?
		return true unless self.content_text.blank?
		components_have_content = false
		self.components.each do |c|
			components_have_content = c.has_content?
			break if components_have_content == true
		end
		components_have_content
	end
	
	## now comes the part of merging in another 
	## so we need sax parser.
	## and we want a pipeline.
	## i want a method called add_book somewhere.

	## reset's everything.
	def reset
		self.state = "off"
		self.content_text = ""
		self.title_text = ""
		self.components.each do |c|
			c.reset
		end
	end

	def update_to_remote
		## will have to put the mappping first.
		## then we have to send the documents in bulk.
		delete_and_create_index($remote_es_client)
		bulk_arr = []
		## will hav to scroll all.
		r = Elasticsearch::Persistence.client.search index: get_index_name, scroll: '1m', body: {
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
					_index: get_index_name, _id: hit._id, _type: "_doc", data: JSON.parse(hit._source.to_json)
				}
			}
		end

		while r = Elasticsearch::Persistence.client.scroll(body: { scroll_id: r['_scroll_id'] }, scroll: '5m') and not r['hits']['hits'].empty? do
			scroll_response = Hashie::Mash.new r
			scroll_response.hits.hits.each do |hit|
				bulk_arr << {
					index: {
						_index: get_index_name, _id: hit._id, _type: "_doc", data: JSON.parse(hit._source.to_json)
					}
				}
				if bulk_arr.size > 100
					puts "bulking ----------------"
					response = $remote_es_client.bulk body: bulk_arr
					puts response.to_s
					bulk_arr.clear
				end
			end
        end
        $remote_es_client.bulk body: bulk_arr
	end

	###################################################################3
	##
	##
	## UTILITY
	##
	##
	####################################################################

	def log(defi)
		puts defi
		puts self.to_json
		puts "--------------------"
	end

	def clear_numbers_newlines_and_excess_spaces(text)
		text.strip.gsub(/\n|\r|\t/,' ').gsub(/\d|\./,'')
	end

	#####################################################################
	##
	##
	## OVERRIDES
	##
	##
	#####################################################################

	def as_json(options={})
		result = super(options)
		unless self.components.blank?
			self.components.map{|c|
				result.merge!({c.name.to_s => c.as_json})
			}
		end
		result
	end

end	