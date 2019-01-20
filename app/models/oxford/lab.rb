class Oxford::Lab < Oxford::Oxford

	def get_topics
		if self.topics.blank?

			self.topics = []

			s = IO.read(textbook_file_path)
			
			s.force_encoding('UTF-8')
			
			s = s.encode('UTF-8', 'binary', invalid: :replace, undef: :replace, replace: '')

			s.scan(/Chapter\s\d+\n{2}(?<contents>[A-Za-z\n\s\d\(\)\-&\/\:\.]+)\d+\n/) do |contents|
			
				#the_title = title[0].split(/\n/)[0]
				
				contents[0].split(/\n/).each do |content|

					self.topics << content.gsub(/\d+/,'')

				end
			
			end

			self.topics = self.topics.flatten.map!{|c| c.gsub(/\d+/,'').strip}.reject{|c| c.blank?}.compact.uniq
			
		end

		self.topics

	end	

	def title_processor(line)
		section_name = nil
		
		line.strip.scan(/^(?<title>[A-Za-z\n\s\d\(\)\-&\/\:\.]+)$/) do |title|

			applicable_topics = get_topics.select{|c| title[0].strip == c}

			if applicable_topics.size > 0
				return ["on",clear_numbers_newlines_and_excess_spaces(title[0])]
			else
				return ["off",title[0]]
			end
		end
		return ["off",line]
	end

end