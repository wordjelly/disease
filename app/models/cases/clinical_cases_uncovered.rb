class Cases::ClinicalCasesUncovered < SaxObject

	def get_topics

		if self.topics.blank?

			self.topics = []

			s = IO.read(textbook_file_path)
			
			s.force_encoding('UTF-8')
			
			s = s.encode('UTF-8', 'binary', invalid: :replace, undef: :replace, replace: '')

			s.scan(/CASE\s\d+\n/) do |title|
				

				
				self.topics << title[0].strip
			
			end

			self.topics = self.topics.flatten.map!{|c| c.gsub(/^\.\s/,'').gsub(/\d+/,'').strip}.reject{|c| c.blank?}.compact.uniq

			
		end

		self.topics = self.topics.map{|c| 
			c = c.gsub(/^\.\s/,'').gsub(/\n\n?History/,'')
			c
		}

		#puts self.topics.to_s
		#exit(1)

		self.topics

	end

end