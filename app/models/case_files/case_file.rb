class CaseFiles::CaseFile < SaxObject

	def get_topics

		if self.topics.blank?

			self.topics = []

			s = IO.read(textbook_file_path)
			
			s.force_encoding('UTF-8')
			
			s = s.encode('UTF-8', 'binary', invalid: :replace, undef: :replace, replace: '')

			s.scan(/Case\s\d+\n(?<title>[A-Z][A-Za-z\s\-\"\'\d\’\,\“\”]+)\./) do |title|
								

				# you can only keep the part before the \n.
				t = title[0]
				if t.index("\n")
					t = t[0,t.index("\n")]
				end

				self.topics << t.strip
			
			end

			self.topics = self.topics.flatten.map!{|c| c.gsub(/^\.\s/,'').strip}.reject{|c| c.blank?}.compact.uniq

			
		end

		
		#puts self.topics.to_s
		#exit(1)

		self.topics

	end

	def title_processor(line)
		section_name = nil
		#puts line.to_s
		
		line.strip.scan(/(?<title>[A-Za-z\s\-\"\'\d\’\,\“\”]+)/) do |title|

			applicable_topics = get_topics.select{|c| title[0].strip == c}

			if applicable_topics.size > 0
				return ["on",title[0] + ":"]
			else
				return ["off",title[0]]
			end
		end
		return ["off",line]
	end

	def clinical_approach_processor(line)
		line.strip.scan(/CLINICAL APPROACH/) do |match|
			return ["on",line.strip]
		end
		return ["off",line.strip]
	end

	def treatment_processor(line)
		line.strip.scan(/TREATMENT/) do |match|
			return ["on",line.strip]
		end
		return ["off",line.strip]
	end


	def add_line(response_text)
		if self.state == "on"
			## is the self _doc ?
			## in that case, if anything was already there, it should be committed.
			## all the children should be cleared.
			unless response_text.blank?
				if self.name == "_doc"
					if self.title_text.blank?
						self.title_text = response_text
					else
						## a little hack to add the second line of text also into the title
						## in the title processor we make it end with a colon, and detect that here. 
						## so the second line also gets added to the title.
						## that's because in this book, some of the titles, were two lines.
						if self.title_text =~ /\:$/
							self.title_text += " " + response_text
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

end