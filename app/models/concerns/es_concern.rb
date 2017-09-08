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
	end
end
