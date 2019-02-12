class CrashCourse::CrashCourse < SaxObject

	def get_topics

		if self.topics.blank?

			self.topics = []

			s = IO.read(textbook_file_path)
			
			s.force_encoding('UTF-8')
			
			s = s.encode('UTF-8', 'binary', invalid: :replace, undef: :replace, replace: '')

			s.scan(/\d\.\s(?<title>[A-Z][A-Za-z\s]+)\.\s\./) do |title|
				t = title[0]
				self.topics << t.strip
			end

			self.topics = self.topics.flatten.map!{|c| c.gsub(/^\.\s/,'').strip}.reject{|c| c.blank?}.compact.uniq

			
		end

		puts self.topics.to_s
		puts self.topics.size
		exit(1)
		self.topics
	
	end

	def title_processor(line)
		section_name = nil
		#puts line.to_s
		
		line.strip.scan(/(?<title>[A-Za-z\s\-\"\'\d\’\,\“\”]+)/) do |title|

			applicable_topics = get_topics.select{|c| title[0].strip == c}

			if applicable_topics.size > 0
				return ["on",title[0] + ":"]
			else
				return ["off",title[0]]
			end
		end
		return ["off",line]
	end

	

end