class DiagnosesController < ApplicationController
	
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

  	@diagnoses = []
  	
	r = Entity.gateway.client.search index: Entity.index_name, scroll: '1m', body: JSON.parse(query)

	m = Hashie::Mash.new r

	m.aggregations.top.buckets.each do |bucket|
		puts bucket.to_s
		d = Diagnosis.new(title: bucket['key'], workup: [])
		#puts " ---------- workup ----------"
		#puts bucket.workup
		#puts " ---------- workup -> hits --------"
		#puts bucket.workup.hits
		#puts " ---------- workup -> hits -> hits --------"
		#puts bucket.workup.hits.hits
		bucket.workup.investigations.hits.hits.each do |hit|
			d.workup << hit._source.name
		end
		IO.write("diagnoses.json",JSON.generate(@diagnoses))
		@diagnoses << d

	end

  end

end