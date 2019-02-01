class Cases::Case < SaxObject


	def get_topics

		if self.topics.blank?

			self.topics = []

			s = IO.read(textbook_file_path)
			
			s.force_encoding('UTF-8')
			
			s = s.encode('UTF-8', 'binary', invalid: :replace, undef: :replace, replace: '')

			s.scan(/CASE\s\d+\:(\n\n)?(?<title>[A-Za-z\s]+)\n/) do |title|
				

				
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

	def history_processor(line)
		line.strip.scan(/History/) do |match|
			return ["on",line.strip]
		end
		return ["off",line.strip]
	end

	def examination_processor(line)
		line.strip.scan(/Examination/) do |match|
			return ["on",line.strip]
		end
		return ["off",line.strip]
	end

	def investigations_processor(line)
		line.strip.scan(/Investigations/) do |match|
			return ["on",line.strip]
		end
		return ["off",line.strip]
	end

	def answer_processor(line)
		line.strip.scan(/ANSWER/) do |match|
			return ["on",line.strip]
		end
		return ["off",line.strip]
	end

	def key_points_processor(line)
		line.strip.scan(/KEY POINTS/) do |match|
			return ["on",line.strip]
		end
		return ["off",line.strip]
	end

end