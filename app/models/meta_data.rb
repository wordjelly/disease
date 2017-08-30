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
	

	after_save {
		#puts "saved: #{self.id.to_s}"
	}

	## [Hash] returns the paths of the xml.gz files already downloaded to the pubmed_metadata_files folder
	## structure is: 
	## key -> filename(only name not preceeding path)
	## value -> filename with path.
	def self.zipped_files
		filenames = Dir.glob("#{Rails.root}/vendor/pubmed_metadata_files/*")
		Hash[filenames.map{|c| c = c.split(/\//).last}.zip(filenames)]
	end

	
	## downloads all the metadata files from the pubmed ftp url
	## => ftp://ftp.ncbi.nlm.nih.gov/pubmed/baseline
	def self.download(n)
		files_already_downloaded = self.zipped_files
		server = "ftp.ncbi.nlm.nih.gov"
		BasicSocket.do_not_reverse_lookup = true
		Net::FTP.open(server) do |ftp|
		  ftp.passive = true
		  ftp.login
		  ftp.chdir("/pubmed/baseline")
		  files = ftp.list("*.gz")
		  puts "got ftp files list"
		  files.each_with_index { |file, i|
		  	break if i >= n
		  	puts "downloading file: #{i + 1}"
		  	begin
			    filename = file.split(/\s/).last
			    unless files_already_downloaded[filename]
				  	ftp.getbinaryfile(filename, "#{Rails.root}/vendor/pubmed_metadata_files/#{filename}",1024) do |chunk|
				  	end
				  	puts "downloaded file : #{filename} number: #{i + 1} of #{files.size}"
				else
					puts "file : #{filename} already exists"
			  	end
		  	rescue => e
		  		puts "encountered error downloading file: #{filename}"
		  	end
		  }
		end
	end

	def self.unzip
		system("sh #{Rails.root}/lib/unzip_metadata_files.sh")
	end

	def self.index_metadata_file(file_path)
		puts "adding metadata from: #{file_path} to index"
		proc = Proc.new { |item|}
		handler = Yielder.new(proc,MetaData)
		io = IO.read(file_path)
		Ox.sax_parse(handler, io)
	end

	def self.index_metadata(max_files)
		puts "rebuilding index"
		MetaData.create_index! force:true
		puts "index rebuilt."
		files = Dir.glob("#{Rails.root}/vendor/pubmed_metadata_unzipped/*")
		puts "there are: #{files.size} unzipped files to index" 
		files.each_with_index {|file_path,count|
			puts "indexing file: #{count}"
			self.index_metadata_file(file_path)
			break if count > max_files
		}
	end

	## first downloads(first_n_files) , provided that file is not already downloaded.
	## the unzips all files(whether earlier downloaded or downloaded new)
	## then indexes(first_n_files) into the index
	## before running this def ensure that there are directories in the vendor directory called "pubmed_metadata_files","pubmed_metadata_unzipped", and give them full permissions.
	## currently takes around 7 minutes for 30,000
	## for 800 files: 5600 minutes :
	## 
	def self.pipeline(n)
		self.download(n)
		self.unzip
		start_time = Time.now.to_i
		self.index_metadata(n)
		puts "time taken : #{Time.now.to_i - start_time}"
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
