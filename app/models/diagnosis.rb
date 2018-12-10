require 'elasticsearch/persistence/model'

class Diagnosis
	
	include Elasticsearch::Persistence::Model
	include Concerns::EsConcern
	include Concerns::EsBulkIndexConcern

	attribute :title, String,  mapping: { type: 'keyword' }
	attribute :symptoms, Array,  mapping: { type: 'keyword' }
	attribute :tests, Array,  mapping: { type: 'keyword' }
	attribute :buffer, String, mapping: {type: "text"}

	@@_current_diagnosis = nil

	## @return[Diagnosis] diagnosis: returns a new diagnosis, if the line is considered as the beginning of a diagnosis 
	def self.is_diagnosis?(line)	
		diagnosis = nil
		line.strip.scan(/^(?<title>[A-Z\-\s]+$)/){|title|
			title_without_space = title[0].gsub(/\s/,'')
			if title_without_space =~ /CHAPTER/
				puts "got chapter"
			else
				diagnosis = Diagnosis.new(title: title[0], buffer: "")
			end
		}
		diagnosis
	end

	## each term has to be created
	## 


	## two options, how well does something qualify as a symptom
	## how well does it qualify as a sign
	## how well does it qualify as a test
	## distance from workup.
	## whereever it happens to score the highest.
	## that is where it will go.
	## as a function of what ?
	## closest to.
	## then get a count of that
	## so put into an array
	## sublime_text has 300 entries
	## a new document for each occurrence.
	## yes can be done,
	## but how do we split ?
	## extract phrases ?
	def self.parse_diagnosis_data
		puts $tgr
		Diagnosis.all.each  do |diag|

			
			word_positions = {}

			diag.buffer.split(/\./).each do |sentence|
				## now split this into the individual texts.
				if sentence.strip.blank?
				else
					s = sentence.strip
					tagged = $tgr.add_tags(s)
					word_list = $tgr.get_words(s)
					word_list.keys.each do |term|
						word_positions[term] = [diag.buffer.index(term)] unless word_positions[term]
					end
				end
			end

			puts "word positions are:"
			puts word_positions.to_s

			## now we have the word positions.
			## now look, how far each word is from the individual things.
			word_positions.keys.each do |term|
				
				information = Information.new
				
				distances = {}
				
				if word_positions[term][0] != nil

					if word_positions["Signs"]
						distances["Signs"] = word_positions[term][0] - word_positions["Signs"][0] 
					end

					if word_positions["Symptoms"]
						distances["Symptoms"] = word_positions[term][0] - word_positions["Symptoms"][0]
					end

					if word_positions["Work-Up"]
						distances["Work-Up"] = word_positions[term][0] - word_positions["Work-Up"][0]
					end

					if word_positions["Treatment"]
						distances["Treatment"] = word_positions[term][0] - word_positions["Treatment"][0]
					end
					
					distances = distances.sort_by { |k,v|  v}.to_h

					positive_distances = distances.keys.select{|c| distances[c] > 0}

					information.closest = positive_distances[0] unless positive_distances.blank?

					information.diagnosis_name = diag.title

					information.name = term

					add_bulk_item(information) unless information.closest.blank?

				end

			end			

			#flush_bulk

			#exit(1)

		end
		## we go over all the diagnosis
		## we parse the buffer.
		## we calculate distance from "symptoms", "signs", "work-up", "treatment"
		## we divide into phrases.
		## we locate the positions of 
	end

	def self.parse_textbook(txt_file_path="#{Rails.root}/vendor/wills_eye_manual.txt")
		
		Diagnosis.create_index! force: true
		@@_current_diagnosis = nil
		IO.read(txt_file_path).each_line do |l|
			if diagnosis = is_diagnosis?(l)
				puts "got a diagnosis: #{diagnosis.title}"
				if @@_current_diagnosis
					puts "saving diagnosis."
					puts @@_current_diagnosis.attributes
					add_bulk_item(@@_current_diagnosis)
				end 
				@@_current_diagnosis = diagnosis
			else
				puts "adding buffer line #{l}"
				@@_current_diagnosis.buffer += l if @@_current_diagnosis
			end
		end
		flush_bulk
	end

end