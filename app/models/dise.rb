require 'elasticsearch/persistence/model'
class Dise

	include Elasticsearch::Persistence::Model
	include Concerns::EsConcern
	include Concerns::EsBulkIndexConcern

	
	attribute :name, String,  mapping: { type: 'keyword' }
	attribute :symptoms, Array,  mapping: { type: 'keyword' }
	attribute :symptom_tfidf,Float,  mapping: { type: 'float' }
		
	def self.get_test
		document = Dise.gateway.client.get index: Dise.index_name, type: Dise.document_type, id: "test"
		document
	end

	
	def crud
		
		self.name = "test"
		
		self.symptoms = ["fever"]

		puts "creating index: #{Dise.gateway.create_index!}"

		Dise.gateway.client.update index: self.class.index_name, type: self.class.document_type, id: self.name, body: {
			scripted_upsert: true,
			script: {
				source: "if(ctx._source.symptoms == null){ctx._source.symptoms = new ArrayList(); ctx._source.symptoms.add(params.symptoms[0]); ctx._source.name = params.name} else { ctx._source.symptoms.add(params.symptoms[0])}",
				lang: "painless",
				params: {
					name: self.name,
					symptoms: self.symptoms,
					symptom_tfidf: self.symptom_tfidf
				}
			},
			upsert: {
				
			}
		}
	end

	


	
	

	

	
	


	## @return [Hash] of disease names.
	## key -> disease name
	## value -> 1
	def self.disease_hash
		diseases = {}
		IO.readlines("#{Rails.root}/vendor/pubmed_diseases_list.txt").each do |line|
			disease = line.split(/\t/)[0]
			diseases[disease] = 1
		end
		diseases	
	end


##########################################################################
##
##
## WORKING CODE
##
##
##########################################################################
	
	######################################################################
	##
	##
	## CREATE INDEX FROM THE NATURE SYMPTOMS CSV FILES.
	##
	## CALL self.build, and it will drop the diseases index, and recreate it.
	## this only reads from the file mentioned in the default argument in the self.build function.
	## 
	######################################################################

	def create_or_update_request_body
		{
			scripted_upsert: true,
			script: {
				source: "if(ctx._source.symptoms == null){ctx._source.symptoms = new ArrayList(); ctx._source.symptoms.add(params.symptoms[0]); ctx._source.name = params.name} else { ctx._source.symptoms.add(params.symptoms[0])}",
				lang: "painless",
				params: {
					name: self.name,
					symptoms: self.symptoms,
					symptom_tfidf: self.symptom_tfidf
				}
			},
			upsert: {
				
			}
		}
	end

	def self.build(file_path="#{Rails.root}/vendor/pubmed_symptoms_to_diseases_tfidf.txt")

		Dise.gateway.delete_index!
		Dise.gateway.create_index!

		IO.readlines(file_path).each do |line|
			process_line(line)
		end
		flush_bulk
	end


	## @param[String] line : string, from pubmed_symptoms_to_diseases_tfidf
	def self.process_line(line)
		disease = Dise.new
		symptom_name = nil
		symptom_tfidf = nil
		## we want to aggregate by number of symptoms.
		## filter by symptom and aggregate by symptoms
		## lets just gather in memory.
		line.split("\t").each_with_index{|value,key|
			case key
			when 0
				disease.symptoms = [value]
			when 1
				disease.name = value
			when 2

			when 3
				disease.symptom_tfidf = value[0..value.size - 2].to_f
			else

			end
		}
		
		## conver this to the create or update request.
		bulk_update_item = {
			update: {
				_index: disease.class.index_name, _type: disease.class.document_type, _id: disease.name, data: disease.create_or_update_request_body
			}
		}

		puts "the bulk update item is:"
		puts bulk_update_item.to_s

		add_bulk_item(bulk_update_item)
	end

	#####################################################################
	##
	## COMPOSITE FUNCTIONS.
	##
	#####################################################################

	def self.composite_query(after=nil)

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
			                    					field: "symptoms",
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

		Dise.gateway.client.search index: Dise.index_name, body:
		{
				query: {
					bool: {
						must: [
							{
								match_all: {}
							}
						],
						filter: {
							term: {
								symptoms: symptom
							}
						}
					}
				},
				aggregations: aggregations
		}

	end

	def self.composite_agg

		symptom = "Edema"
		has_more_results = true
		while has_more_results
			mash = Hashie::Mash.new composite_query
			has_more_results = false if mash.aggregations.my_buckets["buckets"].size == 0
			mash.aggregations.my_buckets["buckets"].each do |bucket|
				puts bucket.to_s
			end	
		end
		

	end


	#####################################################################
	##
	##
	## ASSOCIATION FUNCTIONS.
	##
	##
	#####################################################################
	def self.association_query(symptom,include_fields=[])
		aggregations = {
					co_assoc: {
						terms: {
							field: "symptoms"
						}
					}
				}




		aggregations[:co_assoc][:terms][:include] = include_fields unless include_fields.empty?

		response = Dise.gateway.client.search index: Dise.index_name, body: {
				query: {
					bool: {
						must: [
							{
								match_all: {}
							}
						],
						filter: {
							term: {
								symptoms: symptom
							}
						}
					}
				},
				aggregations: aggregations
			}

		response
	end

	## 
	def self.get_assoc

		aggregation =  {
					common_symptoms: {
						terms: {
							field: "symptoms",
							size: 100
						}
					}
				}

		response = Dise.gateway.client.search index: Dise.index_name, body: {
				query: {
					bool: {
						must: [
							{
								match_all: {}
							}
						]
					}
				},
				aggregations: aggregation
			}
		mash = Hashie::Mash.new response
		mash.aggregations.common_symptoms["buckets"].each do |bucket|
			assoc(bucket["key"])
			exit(1)
		end
	end

	def self.assoc(symptom)

		response = association_query(symptom,[])
		mash = Hashie::Mash.new response	
		primary_symptom_count = nil
		half_strength_symptoms = {}
		mash.aggregations.co_assoc["buckets"].each do |bucket|
			#puts bucket.to_s
			if bucket["key"].downcase == symptom.downcase 
				primary_symptom_count = bucket["doc_count"]
			else
				#puts "primary_symptom_count : #{primary_symptom_count}"
				#puts "bucket doc count:"
				#puts bucket["doc_count"]
				## we only want those symptoms which have fewer counts than this.
				## then we want to sort ascending.

				strength = bucket["doc_count"].to_f/primary_symptom_count.to_f
	
				#puts "the 0.5 minus strength abs is"

				abs_strength = (0.5 - strength).abs

				#puts "symptom :#{bucket['key']} => #{abs_strength}"

				half_strength_symptoms[bucket["key"]] = abs_strength

			end 
		end

		half_strength_symptoms = half_strength_symptoms.to_a.sort { |a, b| a[1] <=> b[1] }[0..5]

		## so now we have to create this 
		symp = Symptom.new
		symp.name = symptom
		symp.associated_symptom_choices = []
		half_strength_symptoms.each do |s|
			symp.associated_symptom_choices << {:name => s[0], :score => s[1]}
		end

		## we want to add this to the bulker.
		#puts symp.associated_symptom_choices.to_s
		symp.save

	end




##########################################################################
##
##
## END
##
##
##########################################################################

end