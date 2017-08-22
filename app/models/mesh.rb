require 'elasticsearch/persistence/model'
class Mesh
	include Elasticsearch::Persistence::Model
	include Es

	before_save{
		arr = []
		self.numbers.map { |e|
			e.scan(/\./) { |match|
				jj = Regexp.last_match
				arr << jj.pre_match
			}
		}
		self.parents = arr.uniq.reject { |e|
			self.numbers.include? e
		}
	}


	##MESH "UI"
	attribute :ui, String, mapping:{type: 'string',index: 'not_analyzed'}

	attribute :parents, String, default: [], mapping: {index: 'not_analyzed'}

	##MESH "MH"
	attribute :name, String
	
	##MESH "MN" -> list of numbers
	attribute :numbers, String, default:[], mapping:{index: 'not_analyzed'}
	
	##MESH "MS"
	attribute :description, String

	##MESH "AN"
	attribute :annotation, String

	##MESH "ENTRY"
	attribute :other_names, String, default:[]

	##these are for use in the meta_data.rb object.
	##where for a given descriptor there are numerous qualifiers.
	attribute :qualifier_names, String, default: [], mapping:{type: 'string'}


end
