require 'elasticsearch/persistence/model'


class Information

	include Elasticsearch::Persistence::Model
	include Concerns::EsConcern
	include Concerns::EsBulkIndexConcern

	attribute :closest, String,  mapping: { type: 'keyword' }
	attribute :name, String, mapping: { type: 'keyword'}
	attribute :diagnosis_name, String, mapping: { type: 'keyword'}

end