class Oxford::Allergy < Oxford::Oxford
	def self.get_allergy_contents(allergy_book_file_path_and_name,contents_file_path_and_name)
		titles = []
		IO.read(allergy_book_file_path_and_name).each_line do |line|
			line.strip.scan(/^(?<title>[A-Z][a-z][A-Za-z\s\)\-\(\–\,\)0-9\+]+)\d+$/) do |title|
				titles << title
			end
		end
		IO.write(contents_file_path_and_name,JSON.generate(titles))
	end
end