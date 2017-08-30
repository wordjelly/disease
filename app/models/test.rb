require 'elasticsearch/persistence/model'
class Test
	include Elasticsearch::Persistence::Model
	attribute :name, String
	attribute :description, String
	attribute :sample_type, String

	##calls the JSON_URL, and parses the file returned to build a database of tests.
	def self.read
		Test.create_index! force: true
		json_tests = JSON.parse(IO.read("#{Rails.root}/vendor/testsearchnames.json"))
		
		counter = 0
		json_tests["data"].each do |test_as_array|
			t = Test.new
			t.name = test_as_array[0]
			t.description = ActionView::Base.full_sanitizer.sanitize(test_as_array[1])
			t.sample_type = test_as_array[2]
			t.save
			puts "saved test: #{counter}"
			counter+=1
		end

	end

end