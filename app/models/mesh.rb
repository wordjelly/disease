require 'elasticsearch/persistence/model'
class Mesh
	include Elasticsearch::Persistence::Model
	
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
	attribute :ui, String

	attribute :parents, String, default: []

	##MESH "MH"
	attribute :name, String
	
	##MESH "MN" -> list of numbers
	attribute :numbers, String, default:[]
	

	##MESH "MS"
	attribute :description, String

	##MESH "AN"
	attribute :annotation, String

	##MESH "ENTRY"
	attribute :other_names, String, default:[]

	attribute :qualifier_names, String, default: []


end
