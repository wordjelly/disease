require 'elasticsearch/persistence/model'
class MetaData
	include Elasticsearch::Persistence::Model
	include Concerns::XmlConcern
	attr_accessor :mesh

	def self.item_element
		"PubmedArticle"
	end

	
	def tag_and_text
		if current_tag =~ /DescriptorName/
			#@mesh = Mesh.new({:ui => })
		
		end
	end

	def gather_element(element_name)
		if super(element_name)
			puts "printing element."
			puts current_tag
			puts current_tag_text
			puts current_tag_attributes_hash	
		end
	end
end
