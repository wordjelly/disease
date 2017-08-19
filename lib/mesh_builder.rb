module MeshBuilder
	##returns the contents of the line after the equal to sign
	def self.line_content(line)
		line_content = nil
		line.scan(/=(?<content>.*)$/) { |match| 
			l = Regexp.last_match
			line_content = l[:content].strip
		}
		line_content
	end

	def self.read_ascii_bin
		
		record = false
		m = nil
		records = 0

		IO.readlines("#{Rails.root}/vendor/MESH_ASCII_2017.bin").each do |line|
			
			exit if records > 10
			
			if line =~ /^\*NEWRECORD/
				if m
					m.save
					puts "saving record: #{records}"
					records+=1
				end
				m = Mesh.new
			end

			
			if line=~/^MH/
				m.name = line_content(line)
			elsif line=~/^MN/
				m.numbers << line_content(line)
			elsif line=~/^MS/
				m.description = line_content(line)
			elsif line=~/^AN/
				m.annotation = line_content(line)
			elsif line=~/^ENTRY/
				m.other_names << line_content(line)
			elsif line=~/^UI/
				m.ui = line_content(line)
			end
			

			
		end
	
	end
end