require 'elasticsearch/persistence/model'
require 'net/ftp'
class Symptom
	include Elasticsearch::Persistence::Model
	attribute :name, String
	attribute :associated_symptom_choices, Array[Hash], mapping: {
		type: "object",
		properties: {
			name: {
				type: "keyword"
			},
			score: {
				type: "float"
			}
		}
	}

	## @return [Hash] of symptom names.
	## key -> symptom name
	## value -> 1
	def self.symptom_hash
		symptoms = {}
		IO.readlines("#{Rails.root}/vendor/pubmed_symptoms_list.txt").each do |line|
			symptom = line.split(/\t/)[0]
			symptoms[symptom] = 1
		end
		symptoms		
	end

	def self.read

		IO.readlines("#{Rails.root}/vendor/pubmed_symptoms_list.txt").each do |line|
			symptom = line.split(/\t/)[0]
			puts "symptom is: #{symptom}"
			meshes = Mesh.search \
			filter: {
				term: {
					name: {
						value: symptom
					}
				}
			}

			numbers = meshes.results.map{|mesh| 
				mesh = mesh.numbers
			}.flatten

			puts numbers.to_s

			##now query the metadata, filtering only 


			gets.chomp
		end


	end

end