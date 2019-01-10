class Paediatric::Algorithm < SaxObject

	def add_line(response_text)
		if self.state == "on"
			response_text_without_numbers = response_text.gsub(/\d/,'')
			unless response_text_without_numbers.strip.blank?
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
		
		line.strip.scan(/^(?<title>Chapter)$/) do |title|
			if title[0]

				return ["on",clear_numbers_newlines_and_excess_spaces(title[0])]			
			else
				return ["off",title[0]]
			end
		end
		return ["off",line]
	end

	## first we configure the json object.
	def investigations_processor(line)
		line.strip.scan(/INVESTIGATIONS/) do |match|
			return ["on",line.strip]
		end
		return ["off",line.strip]
	end	

	def management_processor(line)
		line.strip.scan(/MANAGEMENT/) do |match|
			return ["on",line.strip]
		end
		return ["off",line.strip]
	end

	## first we configure the json object.
	def differential_diagnosis_processor(line)
		line.strip.scan(/DIFFERENTIAL DIAGNOSIS/) do |match|
			return ["on",line.strip]
		end
		return ["off",line.strip]
	end

end