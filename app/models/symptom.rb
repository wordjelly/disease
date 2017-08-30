require 'elasticsearch/persistence/model'
require 'net/ftp'
class Symptom
	include Elasticsearch::Persistence::Model
	attribute :name, String

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