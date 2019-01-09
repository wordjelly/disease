class Obstetrics::ObsObject < SaxObject
	def title_processor(line)
		section_name = nil
		line.scan(/^\d\s(?<title>[A-Za-z\s]+)$/) do |title|
			if title[0]
				return ["on",clear_numbers_newlines_and_excess_spaces(title[0])]			
			else
				return ["off",title[0]]
			end
		end
		return ["off",line]
	end
end