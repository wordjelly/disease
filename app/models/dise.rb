require 'elasticsearch/persistence/model'
class Dise

	include Elasticsearch::Persistence::Model
	include Concerns::EsConcern
	include Concerns::EsBulkIndexConcern

	
	attribute :name, String
	attribute :symptoms, Array
	attribute :symptom_tfidf, Float
		
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
				disease.symptom = value
			when 1
				disease.name = value
			when 2

			when 3
				disease.symptom_tfidf = value[0..value.size - 2].to_f
			else

			end
		}
		puts "creating record."
		puts disease.attributes.to_s
		add_bulk_item(disease)
	end

	
	def self.index_pubmed_symptoms_to_disease_tfidf(file_path="#{Rails.root}/vendor/pubmed_symptoms_to_diseases_tfidf.txt")
		Dise.gateway.delete_index!
		IO.readlines(file_path).each do |line|
			process_line(line)
		end
		flush_bulk
	end


	def inter_symptom_associations

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