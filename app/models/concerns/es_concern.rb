module Concerns::EsConcern
	extend ActiveSupport::Concern
	included do 
		## returns a count of all records in the mesh index.
		def self.get_count	
			return 0 if !self.gateway.client.indices.exists? index:self.index_name
			count = self.count \
				query: {
					match_all:{

					}
				}
			count
		end

		## returns all the documents in the index.
		## default size is 100
		def self.get_all(size=100)
			all_docs = self.search \
				size: size,
				query: {
					match_all: {

					}
				}
			all_docs.results
		end

		## @param [String] search_class : (Required) the name of the class which implements the EsConcern, and in which we have to page the aggregations.
		## @param [String] field_name : (OPTIONAL), the name of the field on which you want ot perform the terms aggregation, this field is required, only if you don't specify your own sources array for the composite aggregation.
		## @param [String] after : (OPTIONAL), the after string for the composite aggregation to page the results. If this remains nil, then it will keep paging the same results again and again.
		## @param [Hash] query : (OPTIONAL), the query for the aggregation, it defaults to match_all
		## @param[Array] sources_array : (OPTIONAL), the sources array for the composite aggregation, 
		## @param[Proc] proc_to_call_on_each_aggregated_term : (REQUIRED), a proc that is to be called on each aggregated term, it will accept two arguments, the term and the #options argument that is passed into this function.
		## @param[Hash] options : a hash of additional options that is passed into the proc alongwith the aggregated term.
		## @return[Array] proc_results : the results of calling the proc each time on the aggregated term.
		def self.paged_aggregation(search_class,field_name,query,sources_array,proc_to_call_on_each_aggregated_term,options)
			after = nil
			has_more_results = true
			proc_results = []
			while has_more_results == true
				mash = Hashie::Mash.new composite_aggregation_structure(search_class,field_name,after,query,sources_array)
				mash.aggregations.composite_buckets["buckets"].each do |bucket|
					#puts "bucket is: #{bucket}"
					after = bucket["key"]["composite_agg"]
					k = proc_to_call_on_each_aggregated_term.call(after,options)
					proc_results << k if k
				end
				has_more_results = false if mash.aggregations.composite_buckets["buckets"].size == 0
			end
			proc_results
		end


		## @param [String] search_class : (Required) the name of the class which implements the EsConcern, and in which we have to page the aggregations.
		## @param [String] field_name : (OPTIONAL), the name of the field on which you want ot perform the terms aggregation, this field is required, only if you don't specify your own sources array for the composite aggregation.
		## @param [String] after : (OPTIONAL), the after string for the composite aggregation to page the results. If this remains nil, then it will keep paging the same results again and again.
		## @param [Hash] query : (OPTIONAL), the query for the aggregation, it defaults to match_all
		## @param[Array] sources_array : (OPTIONAL), the sources array for the composite aggregation, 
		def self.composite_aggregation_structure(search_class,field_name,after,query,sources_array)

			raise "no field name is specified for the terms aggregation." if (field_name.nil? && sources_array.nil?)

			#puts "came to composite aggregation"

			query ||= {
				match_all: {}
			}

			sources_array ||= [
				{ 
                	composite_agg: 
                		{ 
                			terms: 
                				{ 
                					field: field_name,
                					order: "desc" 
                				} 
                		} 
            	}
			]

			aggregations = {
					composite_buckets: {
						composite: {
							size: 100,
			                sources: sources_array
			            }
					}
				}

			if after
				aggregations[:composite_buckets][:composite][:after] = {
					composite_agg: after
				}
			end

			#puts "query is:"
			#puts query.to_s

			#puts "aggregations are:"
			#puts aggregations.to_s

			search_class.constantize.gateway.client.search index: search_class.constantize.index_name, body:
			{
					query: query,
					aggregations: aggregations
			}


		end

	end
end
