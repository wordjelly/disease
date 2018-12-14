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
					word_positions[term] ||= []
					text.scan(/#{Regexp.escape(term)}/){|match| 
						#puts "match is: #{match}"
						#puts "regexp last match."
						#puts Regexp.last_match.offset(0)
						word_positions[term].push(Regexp.last_match.offset(0))
					}
					#puts " ----------- word position[term] is -------------"
					#puts word_positions[term]
					word_positions[term].flatten!
					#puts word_positions[term].to_s
				end
			end
		end


		["Signs","Symptoms","WorkUp","Treatment"].each do |heading|
			word_positions[heading] = word_positions[heading].sort if word_positions[heading]
		end

		## now we have the word positions.
		## now look, how far each word is from the individual things.
		word_positions.keys.each do |term|
			
			distances = {}
			
			unless ["Signs","Symptoms","WorkUp","Treatment"].include? term


				word_positions[term].sort.each do |position|

					["Signs","Symptoms","WorkUp","Treatment"].each do |heading|
						distances[heading] = position - word_positions[heading][0] if word_positions[heading]
					end					

					distances = distances.sort_by { |k,v|  v}.to_h

					positive_distances = distances.keys.select{|c| distances[c] > 0}

					information = Information.new

					information.closest = positive_distances[0] unless positive_distances.blank?

					information.name = term

					information_objects[term] ||= []

					information_objects[term] << information unless information.closest.blank?
	
				end	

			end

		end		

		information_objects
		#puts information_objects.to_s

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