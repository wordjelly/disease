require 'elasticsearch/persistence/model'
class Mesh
	include Elasticsearch::Persistence::Model
	
	################# SYMPTOM => DISEASE TFIDF ############

	def self.assoc
		IO.readlines("#{Rails.root}/vendor/pubmed_symptoms_to_diseases_tfidf.txt").each do |line|
			
			data = line.split(/\t/)
			
			symptom,disease,score = data[0],data[1],data[3]
			
			meshes = Mesh.search \
			query: {
				term: {
					name: {
						value: symptom
					}
				}
			}
			
			meshes.results.each do |mesh|
				existing_assoc = mesh.associated
				existing_assoc.push({
					:name => disease,
					:score => score
					})
				update_result = mesh.update({:associated => existing_assoc})
				puts update_result.to_s
			end

			gets.chomp
		end
	end

	################# MESH ASCII PARSER ###################

	def self.line_content(line)
		line_content = nil
		line.scan(/=(?<content>.*)$/) { |match| 
			l = Regexp.last_match
			line_content = l[:content].strip
		}
		line_content
	end

	def self.read
		record = false
		m = nil
		records = 0
		Mesh.create_index! force: true
		
		IO.readlines("#{Rails.root}/vendor/MESH_ASCII_2017.bin").each do |line|
			
			#exit if records > 10
			
			if line =~ /^\*NEWRECORD/
				if m
					m.save
					puts "saving record: #{records}"
					records+=1
				end
				m = Mesh.new
			end

			
			if line=~/^MH\s/
				m.name = line_content(line)
			elsif line=~/^MN/
				m.numbers << line_content(line)
			elsif line=~/^MS/
				m.description = line_content(line)
			elsif line=~/^AN/
				m.annotation = line_content(line)
			elsif line=~/^ENTRY/
				m.other_names << line_content(line)
			elsif line=~/^UI/
				m.ui = line_content(line)
			end
			

			
		end
	
	end

	before_save{
		arr = []
		self.numbers.map { |e|
			e.scan(/\./) { |match|
				jj = Regexp.last_match
				arr << jj.pre_match
			}
		}
		self.parents = arr.uniq.reject { |e|
			self.numbers.include? e
		}
	}


	############## ATTRIBUTE DEFINITIONS ##################

	##MESH "UI"
	attribute :ui, String, mapping:{type: 'string',index: 'not_analyzed'}

	attribute :parents, String, default: [], mapping: {index: 'not_analyzed'}

	##MESH "MH"
	attribute :name, String, mapping: {index: 'not_analyzed'}
	
	##MESH "MN" -> list of numbers
	attribute :numbers, String, default:[], mapping:{index: 'not_analyzed'}
	
	##MESH "MS"
	attribute :description, String

	##MESH "AN"
	attribute :annotation, String

	##MESH "ENTRY"
	attribute :other_names, String, default:[]

	attribute :associated,Array[Hash], mapping: {
		type: "object",
		properties: {
			name: {
				type: "string"
			},
			score: {
				type: "float"
			}
		}
	}


end
