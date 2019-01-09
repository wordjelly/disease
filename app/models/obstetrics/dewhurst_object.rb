class Obstetrics::DewhurstObject < SaxObject

	def add_line(response_text)
		if self.state == "on"
			unless response_text.blank?
				if self.name == "_doc"
					if self.title_text.blank?
						self.title_text = response_text
					else
						## if the title contains only the words chapter.
						if self.title_text.strip =~ /^Chapter$/
							## make the title the line, since that is the chapter title.
							self.title_text = response_text
						else
							self.content_text += " " + response_text
						end
					end
				else
					self.content_text += " " + response_text
				end
			end
		end
	end


	def title_processor(line)
		section_name = nil
		
		line.strip.scan(/^(?<title>Chapter\s\d+)$/) do |title|
			if title[0]

				return ["on",clear_numbers_newlines_and_excess_spaces(title[0])]			
			else
				return ["off",title[0]]
			end
		end
		return ["off",line]
	end

	def diagnosis_processor(line)
		if (line.strip =~ /^Diagnosis$/) != nil
			return ["on",line.strip]
		else
			return ["off",line.strip]
		end
	end

	def epidemiology_processor(line)
		if (line.strip =~ /^Epidemiology$/) != nil
			return ["on",line.strip]
		else
			return ["off",line.strip]
		end
	end

	def management_processor(line)
		if (line.strip =~ /^Management$/) != nil
			return ["on",line.strip]
		else
			return ["off",line.strip]
		end
	end
end