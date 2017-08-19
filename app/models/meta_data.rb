require 'elasticsearch/persistence/model'
class MetaData
	include Elasticsearch::Persistence::Model
	attribute :current_tag, String
	attribute :current_tag_text, String
	attribute :all_text, String
	

	def self.Root
		"top"
	end

	def print_tag_with_text
		puts "current tag is: #{current_tag}"
		puts "current text is: #{current_tag_text}"
		#all_text += ("#{current_tag}:" + current_tag_text)
		#puts "all text becomes: #{all_text}"
	end

end
