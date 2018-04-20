require 'elasticsearch/persistence/model'
class Test
	include Elasticsearch::Persistence::Model
	include Concerns::EsConcern
	attribute :name, String
	attribute :description, String
	attribute :sample_type, String
	TOTAL_RECORDS = 74
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
	def self.build_index
		if Test.get_count == TOTAL_RECORDS
			puts "tests index exists and uptodate."
			return
		end
		tests_file = IO.read("#{Rails.root}/vendor/simple_test_names.json")
		JSON.parse(tests_file).each_with_index.map{|test_name,key|
			t = Test.new(:name => test_name)
			t.save
		}
		puts "created tests index."
	end


	def self.calculate_test_to_symptom_ratios
		
	end

	## calculate the relevant phrases from inside a test name.
	## first split the name into individual shingles.
	## for each shingle
	## A]
	## filter : [entire name]
	## query : shingle (not followed or preceeded by what it is usually followed by or preceeded by.)
	## B]
	## filter : [must not have entire name]
	## query : shingle (same clause as above.)
	## C]
	## ratio of these two will give you the relevance of using the shingle in place of the term.
	## then for the main correlation

	## still dont know how to do this.
	## see how often the test comes with the disease
	## if a disease is prolific -> it should absorb a percentage of all tests
	## filter with disease : 
	## filter with all other diseases :
	## that's it.
end