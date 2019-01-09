class Oxford::Oxford < SaxObject

	EXCLUDED_FROM_TITLE = ["Definition","Investigation","Treatment","Background","Classification","Epidemiology","Pathology","Pathophysiology","Management","Etiology","Symptoms","Signs","Etiopathogenesis","Differential","Diagnosis","Clinical","Features","Follow-Up","Pathogenesis","Imaging","MRI","Etiologies","Incidence","Causes","Monitoring","Laboratory","Introduction"]

	def self.parse_table_of_contents(file_path,contents_file_name)

		topics = []

		IO.read(file_path).each_line do |line|
			
			line.strip.scan(/^\d+\s(?<title>[A-Za-z0-9\s\'\/\\\-]+)/) do |title|
				topics << title[0]		 
			end
			
			line.strip.scan(/^(?<title>[A-Za-z0-9\s\'\/\\\-]+)\d+/) do |subtitle|

				exclusions = EXCLUDED_FROM_TITLE.select{|c| subtitle[0] =~ /#{Regexp.escape(c)}/i}				

				topics << subtitle[0] if exclusions.blank?

			end

		end

		topics = topics.map!{|c| c.gsub(/\d+/,'').strip}.reject{|c| c.blank?}.compact.uniq

		IO.write("#{Rails.root}/vendor/#{contents_file_name}.txt",JSON.generate(topics))

	end

end