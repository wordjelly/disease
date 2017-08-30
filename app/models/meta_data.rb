require 'elasticsearch/persistence/model'
require 'net/ftp'
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
	attribute :descriptors, String, default: [], mapping: {index: 'not_analyzed'}


	## array of descriptor uis
	## => tag : DescriptorName => UI
	attribute :descriptor_uis, String, default: [], mapping: {index: 'not_analyzed'}
	

	## array of qualifier names
	## => tag : QualifierName
	attribute :qualifiers, String, default: [], mapping: {index: 'not_analyzed'}
	

	## array of qualifier uis
	## => tag : QualifierName => UI
	attribute :qualifier_uis, String, default: [], mapping: {index: 'not_analyzed'}

	def self.item_element
		"PubmedArticle"
	end
	

	after_save {puts "saved: #{self.id.to_s}"}

	###
	###
	### => addRow("medline17n0059.xml.gz.md5","medline17n0059.xml.gz.md5",0,61,"61 B",1481587200,"13/12/2016, 05:30:00");
	###
	###
	##downloads all the metadata files from the pubmed ftp url
	## => ftp://ftp.ncbi.nlm.nih.gov/pubmed/baseline
	def self.download
		server = "ftp.ncbi.nlm.nih.gov"
		BasicSocket.do_not_reverse_lookup = true
		Net::FTP.open(server) do |ftp|
		  ftp.passive = true
		  ftp.login
		  ftp.chdir("/pubmed/baseline")
		  files = ftp.list("*.gz")
		  files.each_with_index { |file, i|
		    filename = file.split(/\s/).last
		  	ftp.getbinaryfile(filename, "/home/bhargav/Github/disease/vendor/pubmed_metadata_files/#{filename}",1024) do |chunk|
		  	end
		  	puts "downloaded file : #{filename} number: #{i + 1} of #{files.size}"
		  }
		end
	end

	def self.build
		MetaData.create_index! force:true
		proc = Proc.new { |item|}
		handler = Yielder.new(proc,MetaData)
		puts "starting to read"
		io = IO.read("#{Rails.root}/vendor/medsample1.xml")
		puts "finished reading."
		Ox.sax_parse(handler, io)
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
