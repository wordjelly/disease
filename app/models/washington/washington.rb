class Washington::Washington < SaxObject

	def get_topics
		
		if self.topics.blank?

			self.topics = []

			s = IO.read(textbook_file_path)
			
			s.force_encoding('UTF-8')
			
			s = s.encode('UTF-8', 'binary', invalid: :replace, undef: :replace, replace: '')

			s = s.gsub(/\n{2}PART/,'\n')

			s.scan(/Preface(?<title>[A-Za-z\s\'\`\’\d+\.\,\-\/\(\)\:]+)\n{2}/) do |title|
				

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

	def general_principles_processor(line)
		line.strip.scan(/GENERAL PRINCIPLES/) do |match|
			return ["on",line.strip]
		end
		return ["off",line.strip]
	end

	def diagnosis_processor(line)
		line.strip.scan(/DIAGNOSIS/) do |match|
			return ["on",line.strip]
		end
		return ["off",line.strip]
	end

	def clinical_presentation_processor(line)
		line.strip.scan(/Clinical Presentation/) do |match|
			return ["on",line.strip]
		end
		return ["off",line.strip]
	end

	def differential_diagnosis_processor(line)
		line.strip.scan(/Differential Diagnosis/) do |match|
			return ["on",line.strip]
		end
		return ["off",line.strip]
	end

	def diagnostic_testing_processor(line)
		line.strip.scan(/Diagnostic Testing/) do |match|
			return ["on",line.strip]
		end
		return ["off",line.strip]
	end

end