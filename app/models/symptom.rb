require 'elasticsearch/persistence/model'
require 'net/ftp'
class Symptom
	include Elasticsearch::Persistence::Model
	attribute :name, String
	attribute :count, Integer
	attribute :associated_symptoms, Array[Hash], mapping: {
		type: "object",
		properties: {
			name: {
				type: "keyword"
			},
			co_occurrence: {
				type: "integer"
			},
			branch_score: {
				type: "float"
			}
		}
	}


	def self.parse_wills_eye_manual_symptoms(txt_file_path="#{Rails.root}/vendor/wills_eye_manual_symptoms.txt")

		IO.read(txt_file_path).each_line do |line|

			## => if its all capital, then its a symptom
			## => split the subsequent paragraphs into
			## => differential diagnosis, based on 
			## => commas, search for them in the diagnosis
			## => and update 100% matches only.
			## => 

		end

	end

	## returns the script and body for a bunch of symptom scores to be updated.
	## if the associated_symptom name exists, then it will update branch_score and co_occurrence if either of these are not null in the incoming associated_symptom.
	## if the name does not exist, the whole associated symptom will be added.
	## if the document does not exist at all, then all the associated symptoms are added.
	## @param[Array] associated_symptom_choices : an array of hashes of the type : [{name : symptom_name, branch_score: , co_occurrence}]
	def update_associated_symptom_scores(associated_symptoms)
		{
			scripted_upsert: true,
			script: {
				source: "
					if(ctx._source.name == null)
						{
							ctx._source.name = params.name;
							ctx._source.associated_symptoms = new ArrayList();
							ctx._source.associated_symptoms.addAll(params.associated_symptoms);
							ctx._source.count = params.count;
						}
					else
						{
							for(int j=0; j < params.associated_symptoms.length; j++){
								
								boolean found = false;
								
								for(int i=0; i < ctx._source.associated_symptoms.length; i++){

									if(ctx._source.associated_symptoms[i].name.equals(params.associated_symptoms[j].name)){

										if(params.associated_symptoms[j].branch_score != null){

											ctx._source.associated_symptoms[i].branch_score = params.associated_symptoms[j].branch_score;	
										}

										if(params.associated_symptoms[j].co_occurrence != null){

											ctx._source.associated_symptoms[i].co_occurrence = params.associated_symptoms[j].co_occurrence;

										}

										found = true;
									}
								}

								if(found == false){
									ctx._source.associated_symptoms.add(params.associated_symptoms[j]);
								}
							}
						}
					
					",
				lang: "painless",
				params: {
					associated_symptoms: self.associated_symptoms,
					name: self.name,
					count: self.count
				}
			},
			upsert: {

			}
		}
	end

=begin
## NO LONGER USED.
	## @param[Array] associated_symptoms : Array of hashes.
	## each hash has to have a :name. It can have a :branch_score, and an :co_occurrence
	def update_associated_symptoms(associated_symptoms)
		{
			scripted_upsert: true,
			script: {
				source: "
					if(ctx._source.name == null)
						{
						 	ctx._source.associated_symptom_choices = new ArrayList();
						 	ctx._source.associated_symptom_choices.addAll(params.associated_symptom_choices); 
						 	ctx._source.name = params.name;
						}
					else 
					 	{ 
					 		ctx._source.associated_symptom_choices.addAll(params.associated_symptom_choices)
					 	}",
				lang: "painless",
				params: {
					associated_symptom_choices: self.associated_symptoms,
					name: self.name
				}
			},
			upsert: {

			}
		}
	end
=end
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