require 'elasticsearch/persistence/model'

class Diagnosis
	
	include Elasticsearch::Persistence::Model

	include Concerns::EsConcern

	include Concerns::EsBulkIndexConcern

	COMPONENTS = ["symptoms","workup","signs","treatment"]


	settings index: { number_of_shards: 1 }, analysis: {
		filter: {
			nGram_filter: {
				type: "nGram",
				min_gram: 1,
				max_gram: 20,
				token_chars: [
					"letter",
					"digit",
					"punctuation",
					"symbol"
				]
			}
		},
		analyzer: {
			nGram_analyzer: {
				type: "custom",
				tokenizer: "whitespace",
				filter: [
					"lowercase",
					"asciifolding",
					"nGram_filter"
				]
			},
			whitespace_analyzer: {
				type: "custom",
				tokenizer: "whitespace",
				filter: [
					"lowercase",
					"asciifolding"
				]
			}
		}
	} 


	attribute :title, String,  mapping: {
		 type: 'keyword', 
		 fields: {
		 	raw: {
		 		type: 'text',
		 		analyzer: "nGram_analyzer",
				search_analyzer: "whitespace_analyzer"
		 	}
		 }
	}
	
	attribute :symptoms, Array,  mapping: {
		type: 'keyword', 
		fields: {
            raw: { 
                type:  'text',
		 	    analyzer: "nGram_analyzer",
				search_analyzer: "whitespace_analyzer"
            }
        }
	}
	
	attribute :workup, Array,  mapping: { 
		type: 'keyword', 
		fields: {
            raw: { 
              	type:  'text',
		 	    analyzer: "nGram_analyzer",
				search_analyzer: "whitespace_analyzer"
            }
        }
	}
	
	attribute :signs, Array, mapping: { 
		type: 'keyword', 
		fields: {
            raw: { 
              	type:  'text',
		 	    analyzer: "nGram_analyzer",
				search_analyzer: "whitespace_analyzer"
            }
        }
	}

	attribute :treatment, Array, mapping: { 
		type: 'keyword', 
		fields: {
            raw: { 
             	type:  'text',
		 	    analyzer: "nGram_analyzer",
				search_analyzer: "whitespace_analyzer"
            }
        }
	}

	attribute :buffer, String, mapping: {type: 'text'}


	attribute :workup_text, String, mapping: { type: 'text'}
	
	attribute :symptoms_text, String, mapping: {type: 'text'}

	attribute :signs_text, String, mapping: {type: 'text'}
	
	attribute :treatment_text, String, mapping: {type: 'text'}


	attribute :workup_started, Boolean, mapping: {type: 'boolean'}
	attribute :symptoms_started, Boolean, mapping: {type: 'boolean'}
	attribute :signs_started, Boolean, mapping: {type: 'boolean'}
	attribute :treatment_started, Boolean, mapping: {type: 'boolean'}

	@@_current_diagnosis = nil

	########################################################
	##
	## EVENTS AND METHODS FOR WILLS EYE MANUAL.
	##
	##
	######################################################
	##@return[String] section_name:  if it is a section, will return the name of the section, otherwise will return nil.
	def self.is_section?(line)

		section_name = nil

		line.scan(/^(?<title>[A-Z\(\)\-\/\s\n\t\r\d\.\']+)$/){|title|
			title_without_space = title[0].gsub(/\s|\d|\./,'')
			if title_without_space =~ /CHAPTER|FIGURE/
	
			elsif title_without_space.blank?

			elsif title[0].gsub(/\s|\d/,'')[-1] == "."

			else
				section_name = title[0].strip.gsub(/\n|\r|\t/,' ').gsub(/\d|\./,'').strip
			end
		}

	end

	## closes all non active hooks.
	def close_hooks(active_hook)
		["signs","symptoms","treatment","workup"].reject{|c| c == active_hook}.each do |hook|
			self.send("#{hook}_started=",false)
		end
	end

	def start_symptoms?(l)
		unless self.symptoms_started == true
			#puts "workup started is not true."
			if (l.strip =~ /Symptoms/) != nil
				self.symptoms_started = true 
				close_hooks("symptoms")
			end
			#puts "self workup started becomes: #{self.workup_started}"
			return self.symptoms_started
		else
			return false
		end
	end

	def symptoms_on?(l)
		self.symptoms_started
	end

	
	def start_signs?(l)
		unless self.signs_started == true
			#puts "workup started is not true."
			if (l.strip =~ /Signs/) != nil
				self.signs_started = true 
				close_hooks("signs")
			end
			#puts "self workup started becomes: #{self.workup_started}"
			return self.signs_started
		else
			return false
		end
	end

	def signs_on?(l)
		self.signs_started
	end

	def start_workup?(l)
		unless self.workup_started == true
			#puts "workup started is not true."
			if (l.strip =~ /Work\-Up/) != nil
				self.workup_started = true 
				close_hooks("workup")
			end
			#puts "self workup started becomes: #{self.workup_started}"
			return self.workup_started
		else
			return false
		end
	end

	def workup_on?(l)
		self.workup_started
	end

	## workup ends when treatment starts.
	def end_workup?(l)
		start_treatment?(l)
	end

	def start_treatment?(l)
		unless self.treatment_started == true
			if (l.strip =~ /Treatment/)
				self.treatment_started = true
				close_hooks("treatment")
			end
			return self.treatment_started
		else
			return false
		end
	end

	def treatment_on?(l)
		self.treatment_started
	end

	def end_treatment?(l)
	end

	## this api needs a great deal of normalization.
	## especially regarding updating to remote.
	## first normalize all this to something called
	## wills.
	## then move to parse churchill.
	## this some kind of sax parser.
	## what i need to define is the tag regex.
	## its start and end.
	## and the section regex.
	## then we can do it for any textbook.
	## today i can finish for wills and churchill.
	## let that be the main plan for today
	## then i also need a list of these tests 
	## and their meanings.
	## to be added into the index.


	#####################################################################
	##
	## STEP ONE : CALL parse_textbook
	##
	#####################################################################

	## @return[Diagnosis] diagnosis: returns a new diagnosis, if the line is considered as the beginning of a diagnosis 
	def self.is_diagnosis?(line)	
		diagnosis = nil
		line.scan(/^(?<title>[A-Z\(\)\-\/\s\n\t\r\d\.\']+)$/){|title|
			title_without_space = title[0].gsub(/\s|\d|\./,'')
			if title_without_space =~ /CHAPTER|FIGURE/
	
			elsif title_without_space.blank?

			elsif title[0].gsub(/\s|\d/,'')[-1] == "."

			else
				diagnosis = Diagnosis.new(title: title[0].strip.gsub(/\n|\r|\t/,' ').gsub(/\d|\./,'').strip, buffer: "", workup_started: false, treatment_started: false, workup_text: "", treatment_text: "", signs_started: false, signs_text: "", symptoms_started: false, symptoms_text: "")
			end
		}
		diagnosis
	end


	

	def self.parse_textbook(txt_file_path="#{Rails.root}/vendor/wills.txt")
		
		s = IO.read(txt_file_path)
		puts "the encoding is: ---- > "
		puts s.encoding
		s.force_encoding('UTF-8')
		s = s.encode('UTF-8', 'binary', invalid: :replace, undef: :replace, replace: '')

		s.split(/\r|\n|\t/).each do |l|

			
			if diagnosis = is_diagnosis?(l)
				#if diagnosis.title =~ /EPISCLERITIS/
				#	puts "proceeding for episcleritis."
				#	gets.chomp
				#end
				add_bulk_item(@@_current_diagnosis) if @@_current_diagnosis
					#if @@_current_diagnosis.title =~ /EPISCLERITIS/
					#	puts "got diagnosis, and with current diagnosis."
					#	puts @@_current_diagnosis.to_json
					#	gets.chomp
					#end
				#end
				@@_current_diagnosis = diagnosis
				#if @@_current_diagnosis
					#if diagnosis.title =~ /EPISCLERITIS/
					#	@@_current_diagnosis = diagnosis
					#	puts "setting new dianosis to episclritis."
					#	gets.chomp
					#end
					#if @@_current_diagnosis.buffer.blank?
					#	@@_current_diagnosis.title += " " + diagnosis.title
					#else
					#puts @@_current_diagnosis.to_json
					#gets.chomp
					#add_bulk_item(@@_current_diagnosis)
					#@@_current_diagnosis = diagnosis
					#end
				#else
				#	puts "setting new diagnosis --------------"
				#	@@_current_diagnosis = diagnosis
					## now we have to proceed.
				#end
			else

				#puts @@_current_diagnosis.title
				#puts "not a diagnosis."

				## its not a diagnosis.
				if @@_current_diagnosis
					

					if @@_current_diagnosis.start_symptoms?(l)
						
					end


					if @@_current_diagnosis.symptoms_on?(l)
						
						@@_current_diagnosis.symptoms_text += l
						
					end

	
					if @@_current_diagnosis.start_signs?(l)
						
					end


					if @@_current_diagnosis.signs_on?(l)
						
						@@_current_diagnosis.signs_text += l
						
					end					


					if @@_current_diagnosis.start_workup?(l)
						
					end

					if @@_current_diagnosis.workup_on?(l)
						
						@@_current_diagnosis.workup_text += l
						
					end

					if @@_current_diagnosis.start_treatment?(l)
						
					end

					if @@_current_diagnosis.treatment_on?(l)
						
						@@_current_diagnosis.treatment_text += l
						
					end 
				end
			end


		end

		flush_bulk

=begin
		IO.read(txt_file_path).each_line do |l|
			if diagnosis = is_diagnosis?(l)
				#puts "got a diagnosis: #{diagnosis.title}"
				if @@_current_diagnosis
					
					if @@_current_diagnosis.buffer.blank?
						@@_current_diagnosis.title += " " + diagnosis.title
					else
						## before adding the bulk item, set the 
						## workup text.
						add_bulk_item(@@_current_diagnosis)
						@@_current_diagnosis = diagnosis
					end
				else
					@@_current_diagnosis = diagnosis
				end 
				
			else
				#puts "adding buffer line #{l}"
				@@_current_diagnosis.buffer += l if @@_current_diagnosis
			end
		end
		flush_bulk
=end


	end


	#####################################################################
	##
	## STEP TWO : CALL parse_diagnosis_data
	##
	#####################################################################


	def self.parse_diagnosis_data

		Information.create_index! force: true
		
		Diagnosis.all.each  do |diag|

			information_objects = Information.derive_information(diag.buffer)

			information_objects.keys.each do |io|
				information_objects[io].each do |info_object|
					info_object.diagnosis_name = diag.title
					info_object.diagnosis_id = diag.id
					add_bulk_item(info_object)
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
		flush_bulk
	end

	
	def self.composite_aggregations(after)
		aggregations = {
					my_buckets: {
						composite: {
							size: 10,
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
			if term == "ANCA"
				puts " --------- DOING ANCA ------------"
				puts "buckets are:"
				puts mash.aggregations.closest_aggregation
				puts mash.aggregations.closest_aggregation["buckets"]
				puts mash.aggregations.closest_aggregation.buckets.to_s
				puts mash.aggregations.closest_aggregation.buckets.size
			end
			return if mash.aggregations.closest_aggregation["buckets"][0]["doc_count"] == 1
			
			if term == "ANCA"
				puts " --------- DOING ANCA ------------"
				puts "buckets are:"
				puts mash.aggregations.closest_aggregation
				puts mash.aggregations.closest_aggregation["buckets"]
				puts mash.aggregations.closest_aggregation.buckets.to_s
				puts mash.aggregations.closest_aggregation.buckets.size
			end

			found_in_diseases = Entity.gather_found_in_diseases(term)
			
			e = Entity.new(name: term, medical_type: mash.aggregations.closest_aggregation["buckets"][0]['key'], found_in_diseases: found_in_diseases, lab_test: 1)


			add_bulk_item(e)
		else
			if mash.aggregations.closest_aggregation["buckets"][0]["doc_count"] > mash.aggregations.closest_aggregation["buckets"][1]["doc_count"]
				found_in_diseases = Entity.gather_found_in_diseases(term)
				e = Entity.new(name: term, medical_type: mash.aggregations.closest_aggregation["buckets"][0]['key'], found_in_diseases: found_in_diseases, lab_test: 1)
				add_bulk_item(e)
			end
		end
	end


	#####################################################################
	##
	## STEP FOUR : ALLOT TO DIAGNOSIS OBJECTS
	##
	#####################################################################

	def self.allot_to_diagnosis
			
		Entity.all.each do |entity|
			
			puts "doing entity #{entity.to_json}"
			
			proc_to_call_on_each_aggregated_term = Proc.new{|diagnosis_id,options|
				
				entity = options["entity"]

				puts "updating diagnosis of: #{diagnosis_id} with medical type: #{entity.medical_type} and name: #{entity.name}"

				if Diagnosis::COMPONENTS.include? entity.medical_type.downcase

					update_hash = {
						update: {
							_index: Diagnosis.index_name,
							_type: "diagnosis",
							_id: diagnosis_id,
							data: { 
								script: 
								{
									source: "ctx._source.#{entity.medical_type.downcase}.add(params.value)",
									lang: 'painless', 
									params: { value: entity.name }
								}
							}
						}
					}

					add_bulk_item(update_hash)

				end
			}
			paged_aggregation("Information","diagnosis_id",{
				term: {
					name: entity.name
				}
			},nil,proc_to_call_on_each_aggregated_term,{"entity" => entity})

			flush_bulk
		end

	end

	###############################################################################################
	##
	##
	##
	## STEP FOUR ACTUAL.
	##
	##
	##
	#################################################################################################


	######################################################################## @param[String] name:
	## @param[Proc] proc_to_call_on_each_hit:
	## @param[Hash] arguments_for_the_proc:
	## @return[nil] : will call the proc supplied on each of the hits that are found. will pass the hit and any other arguments that are supplied to the proc 
	##
	#####################################################################
	def self.find_all_by_name(name,proc_to_call_on_each_hit,arguments_for_the_proc)

		r = Diagnosis.gateway.client.search index: Diagnosis.index_name, scroll: '1m', body: {
			"query" => {
			    "bool" =>  {
			      	"filter" => {
			        	"term" => {
			          		"title" => name
			        	}
			    	}
			    }
			}
		}
			
		initial_response = Hashie::Mash.new r

		initial_response.hits.hits.each do |hit|
			proc_to_call_on_each_hit.call(arguments_for_the_proc.merge(hit: hit))
		end

		while r = Entity.gateway.client.scroll(body: { scroll_id: r['_scroll_id'] }, scroll: '5m') and not r['hits']['hits'].empty? do
			scroll_response = Hashie::Mash.new r
			scroll_response.hits.hits.each do |hit|
				proc_to_call_on_each_hit.call(arguments_for_the_proc.merge(hit: hit))
			end
        end

	end


	def self.clear_workup
		Diagnosis.all.each do |d|

			update_hash = {
				update: {
					_index: Diagnosis.index_name,
					_type: "diagnosis",
					_id: d.id.to_s,
					data: { 
						script: 
						{
							source: "ctx._source.workup = [];",
							lang: 'painless'
						}
					}
				}
			}

			add_bulk_item(update_hash)

		end

		flush_bulk

	end


# so now we have to set the symptoms for the diagnosis.
# how to find the symptoms.
# how to coaggregate them.	

	def self.update_to_remote
		
		bulk_arr = []
		Diagnosis.all.each do |diagnosis|
			update_hash = {
				index: {
					_index: Diagnosis.index_name, _id: diagnosis.id, _type: Diagnosis.document_type, data: diagnosis.as_json
				}
			}
			bulk_arr << update_hash
			if bulk_arr.size > 100
				puts "bulking ----------------"
				response = $remote_es_client.bulk body: bulk_arr
				puts response.to_s
				bulk_arr.clear
			end
		end
		$remote_es_client.bulk body: bulk_arr
	end

end