require 'elasticsearch/persistence/model'

class SaxParser
	
	include Virtus.model
	include Elasticsearch::Persistence::Model
	include Concerns::EsConcern
	include Concerns::EsBulkIndexConcern

	attribute :file_path, String
	attribute :hierarchy, String
	attribute :text, String
	attribute :sax_object_class, String
	attribute :textbook_name, String
	@@root_sax_object
	## @param[String] file_path : path to the file which is to be parsed.
	## @param[String] hierarchy : json_string with the structure of the file to be prepared, basically a bunch of nested SaxObjects represented as json. Will call JSON.parse(hierarchy) before setting hierarchy value.
	## @example : 
=begin
	{
		"name" : "TITLE",
		"regex" : "test", 
		"components" : [
			{
			    "name" : "symptoms", 
				"regex" : "x",
				"components" : []
			},
			{
				"name" : "symptoms", 
				"regex" : "x",
				"components" : []
			},
			{
				"name" : "symptoms", 
				"regex" : "x",
				"components" : []
			},
			{
				"name" : "symptoms", 
				"regex" : "x",
				"components" : []
			}
		]		
	}
=end 
	def parse_file
		text = IO.read(self.file_path)
	end

	## @param[String] textbook_name : REQUIRED : the name of the textbook for which the default hierarchy is being applied
	## @return[Hash] : default json structure, considers the title to be the only block, it is considered to be both searchable and also containing_tests
	## it is the most basic structure possible.
	## if a null json_structure file is passed then this is used.
	def default_json_structure(textbook_name)
		{
			"name" => "_doc",
			"process_with" => "title_processor", 
			"textbook_name" => textbook_name,
			"contains_tests" => true,
			"searchable" => true,
			"components" => []		
		}
	end


	## @param[Hash] args : arguments for the sax_parser.
	## REQUIRED PARAMETERS
	## => : file_path : ( the path to the text file to be read),
	## OPTIONAL PARAMETERS
	## => : textbook_name : if hierarchy is not provided in the arguments, the textbook name MUST be provided.
	## => : hierarchy : (the json string containing the hierarchy for parsing the text file.) will call JSON.parse(args[:hierarchy]) so the hierarchy must be a valid json string representation of a #SaxObject. If textbook name is not provided in the arguments, then hierarchy MUST be provided.
	## First checks if a :hierarchy attribute is provided in the arguments, and tries to load the json_structure from that. If a hierarchy is not provided, will check for the :textbook_name to exist and will use the default hierarchy.
	## will read the file_path and set the "text" attribute to the text in that file. WIll enforce UTF-8 encoding on that text, and replace any invalid bytes with an empty '' string.
	## will throw an error if any of these steps encounters a problem, like if the file cannot be read, or the hierarchy is not a valid json string etc.
	## will call put_index and build an index out of the hierarchy into elasticsearch.
	## the doc_type of this index will be _doc.
	## the fields will be the components defined in the hierarchy, all will have two mappings : 'raw' : which will be the text mapping, and the name of the field itself, which will correspond to a 'keyword' mapping.
	## components, will be treated as nested objects.
	def initialize(args)
		## default hierarchy is used from sax_parser
		raise "please provide the file_path attribute" unless args[:file_path]
		self.file_path = args[:file_path]
		self.text = set_text
		#raise "please provide hierarchy json string" unless args[:hierarchy]
		if args[:hierarchy]
			self.hierarchy = JSON.parse(IO.read(args[:hierarchy]))
		else
			raise "textbook name not provided" unless args[:textbook_name]
			self.hierarchy = default_json_structure(args[:textbook_name])
		end
		self.sax_object_class = args[:sax_object_class] || "SaxObject"
		@@root_sax_object = self.sax_object_class.constantize.new(self.hierarchy)
		@@root_sax_object.textbook_file_path = args[:file_path]
		super(args)
	end

	def set_text
		s = IO.read(file_path)
		s.force_encoding('UTF-8')
		s = s.encode('UTF-8', 'binary', invalid: :replace, undef: :replace, replace: '')
		s
	end

	def analyze_file
		self.text.split(/\r|\n|\t/).each do |line|
			on_line(line)
		end
		puts "saxparser title text"
		puts SaxParser.get_object.title_text.to_s
		puts SaxParser.get_object.content_text.to_s
		SaxParser.get_object.commit
		SaxParser::flush_bulk
	end

	def self.get_object
		@@root_sax_object
	end

	def on_line(l)
		@@root_sax_object.satisfies_condition?(l)
	end	

	def self.switch_off(except)
		@@root_sax_object.switch_off(except)
	end

	########################################################################
	##
	##
	## update test names to all objects.
	##
	##
	########################################################################

	def self.update_workup

		Test.test_to_array.each do |test|

			p = Proc.new{|args|	

				hit = args[:hit]
				
				source = """
					if(ctx._source.workup == null){
						ctx._source.workup = [];
					}
					ctx._source.workup.add(params.test_name)
				"""

				params = {test_name: args[:test_name]}

				update_hash = {
					update: {
						_index: get_object.get_index_name,
						_type: "_doc",
						_id: hit._id.to_s,
						data: { 
							script: 
							{
								source: source,
								lang: 'painless', 
								params: params
							}
						}
					}
				}

				

				add_bulk_item(update_hash)

			}

			r = Elasticsearch::Persistence.client.search index: get_object.get_index_name, scroll: '1m', body: {
				query: {
					match: {
						workup_text: {
							query: test,
							minimum_should_match: '100%'
						}
					}
				}
			}

			initial_response = Hashie::Mash.new r

			initial_response.hits.hits.each do |hit|
				p.call({:test_name => test}.merge(hit: hit))
			end

			while r = Elasticsearch::Persistence.client.scroll(body: { scroll_id: r['_scroll_id'] }, scroll: '5m') and not r['hits']['hits'].empty? do
				scroll_response = Hashie::Mash.new r
				scroll_response.hits.hits.each do |hit|
					p.call({:test_name => test}.merge(hit: hit))
				end
	        end

			flush_bulk

		end

	end

end