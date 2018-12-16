require 'test_helper'

class MeshesControllerTest < ActionController::TestCase



=begin
  test "information collapses phrases" do 

  	text = "green dog is a good dog"
	word_list = $tgr.get_words(text)
	puts "word list before collapse"
	puts word_list
	puts "word list after collapse"
	puts Information.collapse(word_list)

  end
=end

  test "intuit" do 

  	query = '''
  		{
		  "query": {
		    "match_all": {}
		  },
		  "aggs": {
		    "top": {
		      "terms": {
		        "field": "found_in_diseases",
		        "size": 600
		      },
		      "aggs": {
		        "workup": {
		          "filter": {
		            "term": {
		              "medical_type": "WorkUp"
		            }
		          },
		          "aggs": {
		            "investigations": {
		              "top_hits": {
		                "size": 10,
		                "sort": [
		                  {
		                    "lab_test": {
		                      "order": "desc"
		                    }
		                  }
		                ]
		              }
		            }
		          }
		        }
		      }
		    }
		  }
		}
  	'''


  	r = Entity.gateway.client.search index: Entity.index_name, scroll: '1m', body: JSON.parse(query)

	m = Hashie::Mash.new r

	puts m.aggregations

	## what we wanna pack into it, is the diagnoses.
	## we output a simple table and display them.
	## so that we know what we are getting.

  end

  test "full process" do

  	#Test.tests_to_human_readable_json

  	#puts Test.test_to_array

    #Diagnosis.create_index! force: true
	
	#puts " --------- PARSING TEXTBOOK ---------- "
	#Diagnosis.parse_textbook
	
	#puts " --------- building information ---------- "
	#Diagnosis.parse_diagnosis_data
	
	#puts " --------- building entities -------------- "
	#Diagnosis.get_terms

	#puts " --------- alloting diagnosis ------------- "
	#Diagnosis.allot_to_diagnosis

	#puts " --------- updating lab test scores ----------- "
	#Entity.score(Test.test_to_array,"lab_test")

  end

end
