class Textbook

	## @param[String] textbook_file_path : the absolute path of the .txt file containing the textbook[REQUIRED]
	## @param[String] textbook_json_structure_file_path : the absolute path of the .json file which contains the structure of the textbook[REQUIRED]
	## @param[String] sax_object_class : the class that is to be used for instantiating the SaxObject[Optional]. Defaults to SaxObject
	## @param[String] textbook_name : the name of the textbook[REQUIRED]/
	## @return[nil]
	## @working : will call saxparser, and create an index for the textbook, in 
	## elasticsearch. the name of the index will be prefixed by "documents-"
	def self.add_textbook(textbook_file_path,textbook_json_structure_file_path,sax_object_class)

		raise "textbook file path not provided" unless textbook_file_path
		
		raise "textbook json structure file not provided" unless textbook_json_structure_file_path

		sax_object_class ||= "SaxObject"

		sp = SaxParser.new({:file_path => textbook_file_path, :hierarchy => IO.read(textbook_json_structure_file_path), :sax_object_class => sax_object_class})

		## delete and recreate only if it does not exist.
		SaxParser.get_object.delete_and_create_index

		sp.analyze_file		

		SaxParser.update_workup

		puts "updating to remote."
		SaxParser.get_object.update_to_remote

	end


	def self.search_textbooks(query_string)

	end

end