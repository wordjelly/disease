class SaxParser

=begin
	{
		"name" => "TITLE",
		"regex" => "test", 
		"components" => [
			{
			    "name" => "symptoms" 
				"regex" => "x",
				"components" => []
			},
			{
				"name" => "symptoms" 
				"regex" => "x",
				"components" => []
			},
			{
				"name" => "symptoms" 
				"regex" => "x",
				"components" => []
			},
			{
				"name" => "symptoms" 
				"regex" => "x",
				"components" => []
			}
		]		
	}

=end
	
	attr_accessor :current_sax_object
	attr_accessor :hierarchy
	
	def parse_file(file_path,hierarchy)
		## set_encoding
		## put_index
		## build_hierarchy
		## call on_line on each line.
		## call commit as an when needed.
	end

	def set_encoding

	end

	def put_index	
		## add workup, symptoms, signs and treatment to it.
	end

	def build_hierarchy

	end

	def get_object
		self.current_sax_object
	end

	def set_object(l)
		self.current_sax_object = SaxObject.new(self.hierarchy.merge(:title_text => l))
	end

	def on_line(l)
		if l =~ /#{self.hierarchy["regex"]}/
			get_object.commit if get_object
			set_object(l)
		else
			get_object.process_line(l) if get_object
		end
	end	

	def update_test_names_to_workup
		## take the tests and run them against 
		## whatever is defined as the workup in the 
		## 
	end

end