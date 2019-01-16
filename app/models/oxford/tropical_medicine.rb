class Oxford::TropicalMedicine < Oxford::Oxford

	def get_topics
		if self.topics.blank?

			self.topics = []

			s = IO.read(textbook_file_path)
			
			s.scan(/\n{2}(?<title>[A-Z][A-Za-z0-9\(\)\-\s]+)\n/) do |title|
			
				the_title = title[0].split(/\n/)[0]
				
				self.topics << the_title
			
			end

			self.topics = self.topics.flatten.map!{|c| c.gsub(/\d+/,'').strip}.reject{|c| c.blank?}.compact.uniq
			
		end

		self.topics
	end	

=begin
	def topics

	end
	
	def self.get_contents(allergy_book_file_path_and_name,contents_file_path_and_name)
		titles = []
		## first manage the character conversion to utf 8.
		s = IO.read(allergy_book_file_path_and_name)
		it = 0
		## basically only this block is different.
		s.scan(/\n{2}(?<title>[A-Z][A-Za-z0-9\(\)\-\s]+)\n/) do |title|
			the_title = title[0].split(/\n/)[0]
			titles << the_title
		end
		titles = titles.flatten.uniq.compact.map{|c| c.gsub(/\d+/,'').strip}.reject{|c| c.strip.blank? }
		puts titles.size
		IO.write(contents_file_path_and_name,JSON.generate(titles))
	end
=end
	## 

	## here we have only a title processor, we don't go for subsections.
	def title_processor(line)
		section_name = nil
		
		line.strip.scan(/^(?<title>[A-Z][A-Za-z0-9\(\)\-\s]+)$/) do |title|

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