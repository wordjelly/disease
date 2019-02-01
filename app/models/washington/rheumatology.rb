class Washington::Rheumatology < Washington::Washington
	

	def get_topics
		
		if self.topics.blank?

			self.topics = []

			s = IO.read(textbook_file_path)
			
			s.force_encoding('UTF-8')
			
			s = s.encode('UTF-8', 'binary', invalid: :replace, undef: :replace, replace: '')

			

			s.scan(/PART(?<title>[A-Za-z\d\s\.\–\(\)\-]+)/) do |title|
				

				titles = title[0].split(/\n/).reject{|c| (c.blank?) || (c =~ /^[A-Z]/)}

				
				self.topics = titles
			
			end

			self.topics = self.topics.flatten.map!{|c| c.gsub(/^\.\s/,'').gsub(/\d+/,'').strip}.reject{|c| c.blank?}.compact.uniq

			
		end

		self.topics = self.topics.map{|c| c = c.gsub(/^\.\s/,'')
			c
		}
		
		## sometimes general principles of the first topic, and some subsequent sentences get included, we have to get rid of them.
		## remove general_prinicples
		if principles_index = self.topics.index("GENERAL PRINCIPLES")
			self.topics = self.topics.slice(0,principles_index)
		end
		
		
		self.topics

	end

end