class SaxObject

	attr_accessor :regex
	attr_accessor :name
	attr_accessor :title_text
	attr_accessor :content_text
	attr_accessor :components
	attr_accessor :hierarchy
	attr_accessor :state

	def components=(components)
		self.components = []
		components.each do |component|
			self.components << SaxObject.new(component)
		end
	end

	def process_line(line)
		self.state ||= "off"
		if self.components.blank?
			if self.state == "off"
				run_regex(line)
			elsif self.state == "on"
				self.content_text += "line"
			end	
		else
			self.components.each do |component|
				component.process_line(line)
			end
		end
	
	end		

	def run_regex(line)
		if line =~ /#{self.regex}/
			self.state = "on"
			self.content_text += "line"
		end
	end

	def commit
		## save to elasticsearch.
		## convert to json first, then save.
	end

end	