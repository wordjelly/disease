class Obstetrics::EvidenceObject < SaxObject

	## first we configure the json object.
	def title_processor(line)
		line.strip.scan(/^CHAPTER\s\d+(?<title>[A-Za-z0-9\s\-]+)$/) do |title|
			if title[0]

				return ["on",clear_numbers_newlines_and_excess_spaces(title[0])]			
			else
				return ["off",title[0]]
			end
		end
		return ["off",line]
	end	

	## first we configure the json object.
	def background_processor(line)
		line.strip.scan(/Background and prevalence/) do |match|
			return ["on",line.strip]
		end
		return ["off",line.strip]
	end	

	## first we configure the json object.
	def clinical_features_processor(line)
		line.strip.scan(/Clinical Features/) do |match|
			return ["on",line.strip]
		end
		return ["off",line.strip]
	end	

	## first we configure the json object.
	def investigations_processor(line)
		line.strip.scan(/Investigations/) do |match|
			return ["on",line.strip]
		end
		return ["off",line.strip]
	end	

	def risks_processor(line)
		line.strip.scan(/Risks or complications/) do |match|
			return ["on",line.strip]
		end
		return ["off",line.strip]
	end

	## first we configure the json object.
	def management_processor(line)
		line.strip.scan(/Management/) do |match|
			return ["on",line.strip]
		end
		return ["off",line.strip]
	end	

end