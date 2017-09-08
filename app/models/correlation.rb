class Correlation
	include Elasticsearch::Persistence::Model
	include Concerns::EsConcern

	

	def self.build_correlation
		Test.get_all.each do |test|
			Symptom.symptom_hash.each do |symptom,value|
				## test name : test
				## symptom name : symptom
				test_and_symptom = MetaData.search \
				query:{
					bool:{
						must:
						[
							{
								match_phrase:{
									abstract_text: test.name
								}
							},
							{
								match_phrase:{
									descriptors: symptom
								}
							}
						]
					}
				}
				puts "test:#{test.name}"
				puts "symptom: #{symptom}"
				puts "test_and_symptom together: #{test_and_symptom.results.size}"		
				gets.chomp		
			end	
		end
	end

end