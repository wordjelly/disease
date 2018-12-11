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


	#####################################################################
	##
	## STEP ONE : CALL parse_textbook
	##
	#####################################################################

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


	#####################################################################
	##
	## STEP TWO : CALL parse_diagnosis_data
	##
	#####################################################################


	def self.parse_diagnosis_data

		Information.create_index! force: true
		
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

		end

	end

	#####################################################################
	##
	## STEP THREE : CALL GET_TERMS
	##
	#####################################################################

	def self.get_terms
		Entity.create_index! force: true
		has_more_results = true
		after = nil
		while has_more_results == true
			mash = Hashie::Mash.new composite_aggregations(after)
			mash.aggregations.my_buckets["buckets"].each do |bucket|
				after = bucket["key"]["symptom_thing"]
				get_closest_for_term(after)
			end
			has_more_results = false if mash.aggregations.my_buckets["buckets"].size == 0
		end
	end

	def self.composite_aggregations(after)
		aggregations = {
					my_buckets: {
						composite: {
							size: 100,
			                sources: [
			                    { 
			                    	symptom_thing: 
			                    		{ 
			                    			terms: 
			                    				{ 
			                    					field: "name",
			                    					order: "desc" 
			                    				} 
			                    		} 
			                	}
			                ]
			            }
					}
				}

		if after
			aggregations[:my_buckets][:composite][:after] = {
				symptom_thing: after
			}
		end

		Information.gateway.client.search index: Information.index_name, body:
		{
				query: {
					match_all: {}
				},
				aggregations: aggregations
		}

	end

	def self.get_closest_for_term(term)
		
		aggregations = {
			closest_aggregation: {
				terms: {
					field: "closest",
					order: {
						_count: "desc"
					}
				}
			}
		}

		response = Information.gateway.client.search index: Information.index_name, body: {
			query: {
				bool: {
					must: [
						{
							match_all: {}
						}
					],
					filter: {
						term: {
							name: term
						}
					}
				}
			},
			aggregations: aggregations
		}

		mash = Hashie::Mash.new response
		
		if mash.aggregations.closest_aggregation["buckets"].size  == 1
			return if mash.aggregations.closest_aggregation["buckets"][0]["doc_count"] == 1
			e = Entity.new(name: term, medical_type: mash.aggregations.closest_aggregation["buckets"][0]['key'])
			
			add_bulk_item(e)

		else

			if mash.aggregations.closest_aggregation["buckets"][0]["doc_count"] > mash.aggregations.closest_aggregation["buckets"][1]["doc_count"]

				e = Entity.new(name: term, medical_type: mash.aggregations.closest_aggregation["buckets"][0]['key'])

				puts "creating entity"
				puts e.to_json

				add_bulk_item(e)

			end
		end
	end


end