class Wills::WillsObject < SaxObject

	## @return[Array] : 0: "on" OR "off", 1: the formatted line to be added into the content.
	def title_processor(line)
		
		#puts "Came to title processor"
		#exit(1)
		section_name = nil

		line.scan(/^(?<title>[A-Z\(\)\-\/\s\n\t\r\d\.\']+)$/){|title|
			title_without_space = title[0].gsub(/\s|\d|\./,'')
			if title_without_space =~ /CHAPTER|FIGURE/
	
			elsif title_without_space.blank?

			elsif title[0].gsub(/\s|\d/,'')[-1] == "."

			else
				section_name = clear_numbers_newlines_and_excess_spaces(title[0])
				#puts "got section name"
				#exit(1)
			end
		}

		unless section_name.blank?
			#puts "got a section:"
			#puts section_name
			#exit(1)
			return ["on",section_name]
		else
			return ["off",section_name]
		end

	end

	def signs_processor(line)
		if (line.strip =~ /Signs/) != nil
			return ["on",line.strip]
		else
			return ["off",line.strip]
		end
	end

	#9822010841

	def symptoms_processor(line)
		if (line.strip =~ /Symptoms/) != nil
			return ["on",line.strip]
		else
			return ["off",line.strip]
		end
	end

	def workup_processor(line)
		if (line.strip =~ /Work\-Up/) != nil
			return ["on",line.strip]
		else
			return ["off",line.strip]
		end
	end

	def treatment_processor(line)
		if (line.strip =~ /Treatment/) != nil
			return ["on",line.strip]
		else
			return ["off",line.strip]
		end
	end

	def commit
		super
	end

end