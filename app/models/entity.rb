require 'elasticsearch/persistence/model'

class Entity

	include Elasticsearch::Persistence::Model
	include Concerns::EsConcern
	include Concerns::EsBulkIndexConcern

	attribute :name, String,  mapping: { type: 'keyword' }
		
	attribute :medical_type, String, mapping: {type: 'keyword'}
	
	attribute :textbook, String, mapping: {type: 'keyword'}

	attribute :subject, String, mapping: {type: 'keyword'}


end