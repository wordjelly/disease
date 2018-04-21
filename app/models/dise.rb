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

	## for this what i want to do is to follow this process
	## let us say someone presents with pain in the neck.
	## it can be associated with 500 diseases
	## so suppose i know which symptom is present with this symptom half the times, and not half the times.
	## so unless we find symptoms that tend to divide the occorruence of the disesase, it is pointless.
	## so basically take all the diseases, which have this symptom
	## and aggregate by other symptoms count.
	## let us consider a symptom like "fever"
	## let us take "Edema"
	def self.assoc
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
								symptoms: "Edema"
							}
						}
					}
				},
				aggregations: {
					co_assoc: {
						terms: {
							field: "symptoms"
						}
					}
				}
			}
		mash = Hashie::Mash.new response



		mash.aggregations.co_assoc.each do |symptom|
			## we want something that is at exactly 50 percent.
			## then we want to traverse further down.
			## there are 5 things which are present 50% of the times.
			## thereafter , we need to know their degree of correlation with each other.
			## so we score them like that.
		end 

		## so we will get the fields which occur with this field.
		## I want a field that occurs with this field, about 50 of the times.
		## then we divide from there onwards.

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