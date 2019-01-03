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

=begin
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


  end
=end
	
  ## take all the tests and search for them, wherever they are found.
  ## with a minimum should match.
  ## and see what you get.
	
  test "full process" do


  	# so you want to show the first 10 sentences

    Diagnosis.create_index! force: true
	exit(1)    
    #exit(1)
	#puts " --------- PARSING TEXTBOOK ---------- "
	Diagnosis.parse_textbook

	#
	#puts " --------- adding tests ------------- "
	Test.add_direct_test_matches_to_diagnosis

	

	#Diagnosis.update_to_remote

	#puts " --------- building information ---------- "
	#Diagnosis.parse_diagnosis_data
	
	#puts " --------- building entities -------------- "
	#Diagnosis.get_terms

	#puts " --------- alloting diagnosis ------------- "
	#Diagnosis.allot_to_diagnosis

	#puts " --------- clearing entity scores ------------ "
	#Entity.clear_scores

	#puts " --------- updating lab test scores ----------- "
	#Entity.score(Test.test_to_array,"lab_test")

	#puts " -------- clear diagnosis -------- "
	#Diagnosis.clear_workup

	#puts " -------- updating diagnosis with workups ---------- "
	#Entity.update_diagnosis_index


  end

end
