class Oxford::Oxford < SaxObject

	## geriatrics, and general practise, neuro, nephro, respiratory

	def add_topics(s)
		
		titles = []

		s.split(/\r|\n|\t/).each do |line|
			line.scan(/^(?<title>[A-Za-z\s\:\?]+)\s\d+$/) do |title|
				titles << title[0] unless exclude? title[0]
			end
		end		

		titles

	end



end