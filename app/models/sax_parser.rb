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

	attr_accessor :current_sax_object
	@@current_sa_object
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

	## @param[Hash] args : arguments for the sax_parser.
	## it MUST CONTAIN : file_path ( the path to the text file to be read), hierarchy (the json string containing the hierarchy for parsing the text file.), if either of these two are absent, will raise an error.
	## will call JSON.parse(args[:hierarchy]) so the hierarchy must be a valid json string representation of a #SaxObject
	## will read the file_path and set the "text" attribute to the text in that file. WIll enforce UTF-8 encoding on that text, and replace any invalid bytes with an empty '' string.
	## will throw an error if any of these steps encounters a problem, like if the file cannot be read, or the hierarchy is not a valid json string etc.
	## will call put_index and build an index out of the hierarchy into elasticsearch.
	## the doc_type of this index will be _doc.
	## the fields will be the components defined in the hierarchy, all will have two mappings : 'raw' : which will be the text mapping, and the name of the field itself, which will correspond to a 'keyword' mapping.
	## components, will be treated as nested objects.
	def initialize(args)
		raise "please provide the file_path attribute" unless args[:file_path]
		self.file_path = args[:file_path]
		self.text = set_text
		raise "please provide hierarchy json string" unless args[:hierarchy]
		self.hierarchy = JSON.parse(args[:hierarchy])
		self.sax_object_class = args[:sax_object_class] || "SaxObject"
		self.current_sax_object = self.sax_object_class.constantize.new(self.hierarchy)
		@@current_sa_object = self.sax_object_class.constantize.new(self.hierarchy)
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
		## commit the second one only if it has a title.
		SaxParser.get_object.commit
		SaxParser::flush_bulk
	end

	def self.get_object
		@@current_sa_object
	end

	def on_line(l)
		@@current_sa_object.satisfies_condition?(l)
	end	

	def self.switch_off(except)
		@@current_sa_object.switch_off(except)
	end


end