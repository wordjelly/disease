class Textbook

	def self.build_query(text)
		{
			"size" => 100,
		  	"query" => {
		    	"bool" => {
		      		"should" => [
				        {
				          	"match" => {
			            		"title_text.raw" => {
			              			"query" => text,
			              			"boost" => 5
			            		}
				          	}
				        },
				        {
				          	"match_phrase" => {
				            	"searchable" => {
				              		"query" => text,
				              		"slop" => 10,
				              		"boost" => 2
				            	}
				          	}
				        }
		     	 	]
		    	}
		  	},
		  	"aggs" => {
			    "disease_aggs" => {
			      	"terms" => {
			        	"field" => "title_text",
			        	"order" => {
			          		"max_score" => "desc"
			        	}, 
			        	"size" => 100
			      	},
			      	"aggs" => {
			        	"max_score" => {
			          		"max" => {
			           	 		"script" => "_score"
			          		}
			       		},
			        	"workup_aggs" => {
				          	"terms" => {
				            	"field" => "workup",
				            	"size" => 30
				          	}
			        	}
			    	}	
			   	}
		  	}
		}

	end

	def self.hits_to_hash(mash)
		hits_hash = {}
		mash.hits.hits.map{|c|	
			hits_hash[c["_source"]["title_text"]] = c["_source"]["content_text"]
		}
		hits_hash
	end

	def self.search(text)

		query = build_query(text)
		search_hits_array = []
		cli = (Rails.env["development"] || Rails.env["test"]) ? Elasticsearch::Persistence.client : $remote_es_client
		response = cli.search index: "documents-*", body: build_query(text)
		mash = Hashie::Mash.new response
		hits_hash = hits_to_hash(mash)
		#puts "hits hash is:"
		#puts hits_hash.to_s
		#exit(1)
		mash.aggregations.disease_aggs["buckets"].each do |bucket|
			search_hit = {
				:title => bucket["key"],
				:tests => bucket["workup_aggs"]["buckets"].map{|c| c["key"]},
				:content =>  hits_hash[bucket["key"]]
			}
			search_hits_array << search_hit
		end
		search_hits_array
	end	

	## @param[String] textbook_file_path : the absolute path of the .txt file containing the textbook[REQUIRED]
	## @param[String] textbook_json_structure_file_path : the absolute path of the .json file which contains the structure of the textbook[REQUIRED]
	## @param[String] sax_object_class : the class that is to be used for instantiating the SaxObject[Optional]. Defaults to SaxObject
	## @param[String] textbook_name : the name of the textbook[REQUIRED]/
	## @return[nil]
	## @working : will call saxparser, and create an index for the textbook, in 
	## elasticsearch. the name of the index will be prefixed by "documents-"
	def self.add_textbook(textbook_file_path,textbook_json_structure_file_path,sax_object_class,textbook_name=nil)

		raise "textbook file path not provided" unless textbook_file_path
		
		sax_object_class ||= "SaxObject"

		sp = SaxParser.new({:file_path => textbook_file_path, :hierarchy => textbook_json_structure_file_path, :sax_object_class => sax_object_class,:textbook_name => textbook_name})

		SaxParser.get_object.delete_and_create_index

		sp.analyze_file		

		SaxParser.update_workup

		puts SaxParser.get_object.topics.to_s

		puts "updating to remote."
		SaxParser.get_object.update_to_remote



	end

end