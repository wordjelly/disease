class DiagnosisController < ApplicationController
	
  def query
  	'''
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
  end

  def index
  	@diagnosis = []
  	
	r = Entity.gateway.client.search index: Entity.index_name, scroll: '1m', body: JSON.parse(query)

	m = Hashie::Mash.new r

	

  end

end