require 'elasticsearch/persistence/model'
class Dise
	include Elasticsearch::Persistence::Model
	include Concerns::EsBulkIndexConcern

	
	attribute :name, String
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