require 'elasticsearch/persistence/model'

class SaxObject

	include Virtus.model
	
	## name of a function.
	attribute :process_with, String
	attribute :name, String
	attribute :content_text, String
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
	
	COMMON_FIELD_MAPPING = 
	{
		:type => 'keyword', 
		:fields => {
	        :raw => { 
	          	:type =>  'text',
		 	    :analyzer => "nGram_analyzer",
				:search_analyzer => "whitespace_analyzer"
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
		
		######################### BASIC MAPPING ############################
		mapping = {
			self.name.to_sym => {
				:properties => {
		          	:content_text => COMMON_FIELD_MAPPING
	          	}
          	}
		}

		######################## MERGE SEARCHABLE AT ROOT DOC ##############
		mapping[self.name.to_sym][:properties].merge!({
			:searchable => {
				:type => "text"
			}
		}) if self.name == "_doc"


		######################## COPY FIELD TO SEARCHABLE IF SEARCHABLE #####
		unless self.searchable.blank?
			mapping[self.name.to_sym][:properties][:content_text][:copy_to] = "searchable"
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

	## deletes any existing index and recreates it with the defined mappings and settings.
	## @return[Boolean] true if the index was successfully created. 
	def delete_and_create_index
		if (Elasticsearch::Persistence.client.indices.exists? index: "documents")
			Elasticsearch::Persistence.client.indices.delete index: "documents"
		end
		Elasticsearch::Persistence.client.indices.create index: "documents", body: {
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
				#puts "on for title with line: #{response[1]}"
				# prematurely committing.
				# because it thinks that this is the end.
				unless self.content_text.blank?
					commit
					self.state = "on"
					## so it's not getting the second one.
				end
			end
		elsif response[0] == "off"
			self.components.each do |component|
				component.satisfies_condition?(line)
			end
		end
		if self.state == "on"

			## is the self _doc ?
			## in that case, if anything was already there, it should be committed.
			## all the children should be cleared.

			self.content_text += " " + response[1]
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
		unless self.content_text.blank?
			document = { index:  { _index: 'documents', _type: '_doc',  data: self.as_json } }
			SaxParser::add_bulk_item(document)
			reset
		end
	end

	## reset's everything.
	def reset
		self.state = "off"
		self.content_text = ""
		self.components.each do |c|
			c.reset
		end
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
		self.components.map{|c|
			result.merge!({c.name.to_s => c.as_json})
		}
		result
	end

end	