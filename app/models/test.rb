require 'elasticsearch/persistence/model'
class Test
	include Elasticsearch::Persistence::Model
	attribute :name, String
	attribute :description, String
	attribute :sample_type, String

	##calls the JSON_URL, and parses the file returned to build a database of tests.
	def self.read_from_local_file
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

	## scrapes the page http://www.cpmc.org/learning/labtests.html
	## downloads the list of test names, and loads them into test models.
	## writes them to a json file called 'simple_test_names.json'
	def self.read_from_internet
		page = Nokogiri::HTML(open("http://www.cpmc.org/learning/labtests.html"))
		test_names = page.css("a").map{|link|
			if link['href'].to_s=~/healthinfo\/index\.cfm/
				link = link.text
			end
		}.compact.uniq
		IO.write("#{Rails.root}/vendor/simple_test_names.json",JSON.generate(test_names))
	end

	## ensure that the tests file is present at vendor/simple_tests_name.json, as a simple json array of names.
	def self.create_tests
		tests_file = IO.read("#{Rails.root}/vendor/simple_test_names.json")
		JSON.parse(tests_file).each_with_index.map{|test_name,key|
			t = Test.new(:name => test_name)
			puts "key is: #{key}"
			puts "saved: #{t.save}, #{key}"
		}
	end

end