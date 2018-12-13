require 'elasticsearch/persistence/model'

class Diagnosis
	
	include Elasticsearch::Persistence::Model

	include Concerns::EsConcern

	include Concerns::EsBulkIndexConcern

	COMPONENTS = ["symptoms","workup","signs","treatment"]

	attribute :title, String,  mapping: { type: 'keyword' }
	
	attribute :symptoms, Array,  mapping: {
		type: 'keyword', 
		fields: {
            raw: { 
              type:  'text'
            }
        }
	}
	
	attribute :workup, Array,  mapping: { 
		type: 'keyword', 
		fields: {
            raw: { 
              type:  'text'
            }
        }
	}
	
	attribute :signs, Array, mapping: { 
		type: 'keyword', 
		fields: {
            raw: { 
              type:  'text'
            }
        }
	}

	attribute :treatment, Array, mapping: { 
		type: 'keyword', 
		fields: {
            raw: { 
              type:  'text'
            }
        }
	}

	attribute :buffer, String, mapping: {type: 'text'}

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
				#puts "got chapter"
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
				#puts "got a diagnosis: #{diagnosis.title}"
				if @@_current_diagnosis
					#puts "saving diagnosis."
					#puts @@_current_diagnosis.attributes
					add_bulk_item(@@_current_diagnosis)
				end 
				@@_current_diagnosis = diagnosis
			else
				#puts "adding buffer line #{l}"
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

			information_objects = Information.derive_information(diag.buffer)

			information_objects.keys.each do |io|
				information_objects[io].diagnosis_name = diag.title
				information_objects[io].diagnosis_id = diag.id
				add_bulk_item(information_objects[io])
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

	## basically whatever you want to scroll.
	## this is that aggregation.
	## it accepts an after parameter.
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

				#puts "creating entity"
				#puts e.to_json

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
				#Diagnosis.gateway.client.update index: Diagnosis.index_name, type: "diagnosis", id: diagnosis_id, body: { script: { source: "ctx._source.#{entity.medical_type.downcase}.add(params.medical_type)", params: { medical_type: entity.name } } } 

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

					#Diagnosis.gateway.client.update index: Diagnosis.index_name, type: "diagnosis", id: diagnosis_id, body: { script: { source: "ctx._source.#{entity.medical_type}.add(params.medical_type)", params: { medical_type: entity.name } } }
					add_bulk_item(update_hash)

				end
			}
			paged_aggregation("Information","diagnosis_id",{
				term: {
					name: entity.name
				}
			},nil,proc_to_call_on_each_aggregated_term,{"entity" => entity})
		end

	end

	def self.tt

		proc_to_call_on_each_aggregated_term = Proc.new{|diagnosis_id,options|
			entity = options["entity"]
			puts "updating diagnosis of: #{diagnosis_id} with medical type: #{entity.medical_type} and name: #{entity.name}"

			update_hash = {
				update: {
					_index: Diagnosis.index_name,
					_type: "diagnosis",
					_id: diagnosis_is,
					data: { script: { source: "ctx._source.#{entity.medical_type}.add(params.medical_type)", params: { medical_type: entity.name } } }
				}
			}

			#Diagnosis.gateway.client.update index: Diagnosis.index_name, type: "diagnosis", id: diagnosis_id, body: { script: { source: "ctx._source.#{entity.medical_type}.add(params.medical_type)", params: { medical_type: entity.name } } }
			add_bulk_item(update_hash)
		}

		entity = Entity.new(name: "zoster", medical_type: "Signs")

		paged_aggregation("Information","diagnosis_name",{
			term: {
				name: "zoster"
			}
		},nil,proc_to_call_on_each_aggregated_term,{"entity" => entity})
	end

end