require 'elasticsearch/persistence/model'
class MetaData
	include Elasticsearch::Persistence::Model
	include Concerns::XmlConcern
	attr_accessor :mesh

	## => tag : AbstractText
	attribute :abstract_text, String
	
	## => tag : ArticleTitle
	attribute :article_title, String

	
	## array of descriptor names
	## => tag : DescriptorName
	attribute :descriptors, String, default: []


	## array of descriptor uis
	## => tag : DescriptorName => UI
	attribute :descriptor_uis, String, default: []
	

	## array of qualifier names
	## => tag : QualifierName
	attribute :qualifiers, String, default: []
	

	## array of qualifier uis
	## => tag : QualifierName => UI
	attribute :qualifier_uis, String, default: []

	def self.item_element
		"PubmedArticle"
	end
	
	def gather_element(element_name)
		#puts "printing element."
		#puts current_tag
		#puts current_tag_text
		#puts current_tag_attributes_hash
		#puts "is it regex equal to article title ?"
		#puts "#{current_tag.to_s =~ /ArticleTitle/i}"
		#puts "is it equal."
		#puts "#{current_tag.to_s.strip == 'ArticleTitle'}"
		if current_tag.to_s =~ /ArticleTitle/i
			self.article_title = current_tag_text
		elsif current_tag.to_s =~ /AbstractText/i
			self.abstract_text = current_tag_text
		elsif current_tag.to_s =~ /DescriptorName/i
			self.descriptors << current_tag_text
			self.descriptor_uis << current_tag_attributes_hash[:UI]
		elsif current_tag.to_s =~ /QualifierName/i
			self.qualifiers << current_tag_text
			self.qualifier_uis << current_tag_attributes_hash[:UI]
		end
	end
end
