require 'elasticsearch/persistence/model'

class Entity

	include Elasticsearch::Persistence::Model
	include Concerns::EsConcern
	include Concerns::EsBulkIndexConcern

	attribute :name, String,  mapping: { 
		type: 'keyword',
		fields: {
            raw: { 
              type:  'text',
              analyzer: 'english'
            }
        } 
	}
		
	attribute :medical_type, String, mapping: {type: 'keyword'}
	
	attribute :textbook, String, mapping: {type: 'keyword'}

	attribute :subject, String, mapping: {type: 'keyword'}

	attribute :lab_test, Float, mapping: {type: 'float'}

=begin
	attribute :scores,Array[Hash], mapping: {
		type: "object",
		properties: {
			name: {
				type: "keyword"
			},
			score: {
				type: "float"
			}
		}
	}
=end
	

	attribute :found_in_diseases, Array, mapping: {type: 'keyword'}

	## call clear scores,
	def self.clear_scores
		Entity.all.each do |entity|
			## update the lab_test score to 0.
			update_hash = {
				update: {
					_index: index_name,
					_type: "diagnosis",
					_id: entity.id.to_s,
					data: { 
						script: 
						{
							source: "ctx._source.lab_test = 1;",
							lang: 'painless'
						}
					}
				}
			}

			add_bulk_item(update_hash) 
		
		end

	end

	def self.score(array_of_terms,term_type)

	
		array_of_terms.map{|c|

			puts "searching for #{c}"

			document_scores = {}

			r = Entity.gateway.client.search index: Entity.index_name, scroll: '1m', body: {
				"query" => {
				    "bool" =>  {
				      	"filter" => {
				        	"term" => {
				          		"medical_type" => "WorkUp"
				        	}
				    	},
				    	"must" => [
					        {
					          	"match" => {
					            	"name.raw" => {
					            		"minimum_should_match" => "75%",
					            		"query" => c
					            	}
					          	}
					        }
				      	]
				    }
				}
			}
			
			initial_response = Hashie::Mash.new r

			initial_response.hits.hits.each do |hit|
				document_scores[hit._id.to_s] = hit._score.to_s
			end

			while r = Entity.gateway.client.scroll(body: { scroll_id: r['_scroll_id'] }, scroll: '5m') and not r['hits']['hits'].empty? do
				
				scroll_response = Hashie::Mash.new r
				scroll_response.hits.hits.each do |hit|
					puts "entity: #{hit._source.name.to_s}"
					puts hit._source.name.to_s
					puts "score: #{hit._score.to_s}"
					document_scores[hit._id.to_s] = hit._score.to_s
				end
             	
            end
			
			document_scores.keys.each do |id|
				
				update_hash = {
					update: {
						_index: Entity.index_name,
						_type: "entity",
						_id: id,
						data: { 
							script: 
							{
								source: """
									ctx._source.#{term_type} = (ctx._source.#{term_type} + params.score)/2;
								""",
								lang: 'painless', 
								params: { score: document_scores[id].to_f, medical_type: term_type }
							}
						}
					}
				}

=begin
{
										if(item.name == params.medical_type){
											item.score = (item.score + params.score)/2;
										}
									}
=end
				puts update_hash.to_s

				add_bulk_item(update_hash)

			end			

			flush_bulk

		}
	end

	def self.gather_found_in_diseases(name)
		p = Proc.new{|diagnosis_name,options|
			diagnosis_name			
		}
		paged_aggregation("Information","diagnosis_name",{term: {name: {value: name}}},nil,	p,{})
	end

	def self.query_for_lab_test

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

	## takes each 
	def self.update_diagnosis_index
		
		p = Proc.new{|args|	

			hit = args[:hit]
			
			source = ""
			params = {}

			if args[:lab_test] == true
				source = source + "ctx._source.workup.add(params.entity_name);"
				params[:entity_name] = args[:entity_name]
			end

			#puts hit.to_s

			update_hash = {
				update: {
					_index: Diagnosis.index_name,
					_type: "diagnosis",
					_id: hit._id.to_s,
					data: { 
						script: 
						{
							source: source,
							lang: 'painless', 
							params: params
						}
					}
				}
			}

			#puts "update hash."
			#puts update_hash.to_s
			#gets.chomp

			add_bulk_item(update_hash)

		}

		r = Entity.gateway.client.search index: Entity.index_name, scroll: '1m', body: JSON.parse(query_for_lab_test)

		m = Hashie::Mash.new r

		m.aggregations.top.buckets.each do |bucket|
			
			bucket.workup.investigations.hits.hits.each do |hit|
				puts "bucket key is: #{bucket['key']}"
				puts "entity name is : #{hit._source.name}"
				#gets.chomp
				Diagnosis.find_all_by_name(bucket['key'],p,{lab_test: true, entity_name: hit._source.name})
			end

		end

		flush_bulk

	end
end