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

	
	def self.build(file_path="#{Rails.root}/vendor/pubmed_symptoms_to_diseases_tfidf.txt")

		Dise.gateway.delete_index!
		Dise.gateway.create_index!

		IO.readlines(file_path).each do |line|
			process_line(line)
		end
		flush_bulk
	end

	def self.association_query(symptom,include_fields=[])
		aggregations = {
					co_assoc: {
						terms: {
							field: "symptoms"
						}
					}
				}

		aggregations[:co_assoc][:terms][:include] = include unless include_fields.empty?

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

	## @param[Array] symptoms : list of symptoms to check correlations.
	## @return[Hash] symptom => uniqness to the set of symptoms [0 -> 1]
	## this needs to be decided how exactly to base this
	## but hereonwards my next step will be gathering symptoms from textbooks by correlation analysis of distances. and second job is to find the simple correlation of lay man's english to symptoms.
	## after that we can try some gimicks, but the base will be built. 
	def symptom_correlations(symptoms)
		symptoms.each_with_index{|s,key|
			response = association_query(s,symptoms.except(s.to_s))
		}
	end

	## for this what i want to do is to follow this process
	## let us say someone presents with pain in the neck.
	## it can be associated with 500 diseases
	## so suppose i know which symptom is present with this symptom half the times, and not half the times.
	## so unless we find symptoms that tend to divide the occorruence of the disesase, it is pointless.
	## so basically take all the diseases, which have this symptom
	## and aggregate by other symptoms count.
	## let us consider a symptom like "fever"
	## let us take "Edema"
	def self.assoc(symptom="Edema")
		response = association_query(symptom)
		mash = Hashie::Mash.new response	
		primary_symptom_count = nil
		half_strenght_symptoms = {}
		mash.aggregations.co_assoc["buckets"].each do |bucket|
			if bucket["key"] == symptom 
				primary_symptom_count = bucket["doc_count"]
			else
				puts "primary_symptom_count : #{primary_symptom_count}"
				puts "bucket doc count:"
				puts bucket["doc_count"]
				strength = bucket["doc_count"].to_f/primary_symptom_count.to_f
				
				half_strenght_symptoms[bucket["key"]] = (0.5 - strength).abs if strength.between?(0.45,0.55)
			end 
		end


		half_strenght_symptoms = half_strenght_symptoms.to_a.sort { |a, b| a[1] <=> b[1] }[0..5]



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
end