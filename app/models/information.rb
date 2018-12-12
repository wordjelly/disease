require 'elasticsearch/persistence/model'


class Information

	include Elasticsearch::Persistence::Model
	include Concerns::EsConcern
	include Concerns::EsBulkIndexConcern

	attribute :closest, String,  mapping: { type: 'keyword' }
	attribute :name, String, mapping: { type: 'keyword'}
	attribute :diagnosis_name, String, mapping: { type: 'keyword'}
	attribute :diagnosis_id, String, mapping: {type: 'keyword'}
	

	## @return[Array] information_objects : array of information objects, with name and closest added to each object
	def self.derive_information(text)

		information_objects = {}

		word_positions = {}
		text = text.gsub(/\r|\n|\t/,' ')
		text = text.gsub(/Work-Up/,'WorkUp')

		#puts text.to_s

		text.split(/\./).each do |sentence|
			if sentence.strip.blank?
			else
				s = sentence.strip
				tagged = $tgr.add_tags(s)
				word_list = $tgr.get_words(s)
				word_list.keys.each do |term|
					if text.rindex(term)
						word_positions[term] = [text.rindex(term)] unless word_positions[term]
					end
				end
			end
		end

		#puts word_positions.to_json


		## now we have the word positions.
		## now look, how far each word is from the individual things.
		word_positions.keys.each do |term|
			
			information = Information.new
			
			distances = {}
			
			unless ["Signs","Symptoms","Work-Up","Treatment"].include? term

				if word_positions["Signs"]
					distances["Signs"] = word_positions[term][0] - word_positions["Signs"][0] 
				end

				if word_positions["Symptoms"]
					distances["Symptoms"] = word_positions[term][0] - word_positions["Symptoms"][0]
				end

				if word_positions["WorkUp"]
					distances["WorkUp"] = word_positions[term][0] - word_positions["WorkUp"][0]
				end

				if word_positions["Treatment"]
					distances["Treatment"] = word_positions[term][0] - word_positions["Treatment"][0]
				end
				
				#if term == "Retinoscopy"
				#	puts "distances are:"
				#	puts distances.to_s
				#end

				distances = distances.sort_by { |k,v|  v}.to_h

				positive_distances = distances.keys.select{|c| distances[c] > 0}

				information.closest = positive_distances[0] unless positive_distances.blank?

				information.name = term

				information_objects[term] = information unless information.closest.blank?

			end

		end		

		information_objects

	end

	def self.find_by_name(name)
		## we want to aggregate the diagnosis, 
		## and aggregate the diagnosis by a composite query.
		## then update those.
		## so i have to do that composite shit today itself.
		response = Information.gateway.client.search index: Information.index_name, body: {
			query: {
				terms: {
					name: {
						value: name
					}
				}
			}
		}

	end

end