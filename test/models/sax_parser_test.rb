require 'test_helper'

class SaxParserTest < ActiveSupport::TestCase


## this file has to test a multitude of things.
## creates the index
## subclasses the object
## analyzes a file with a single object,
## analyzes a file with multiple objects.
	setup do 


		if (Elasticsearch::Persistence.client.indices.exists? index: "documents")
			puts "deleting index before running test:"
			delete_index_response = Elasticsearch::Persistence.client.indices.delete index: "documents"
			puts "delete index response: #{delete_index_response}"
		end


	end

=begin
	def test_generate_index_mapping_from_hierarchy
		sp = SaxParser.new({:file_path => "#{Rails.root}/vendor/wills.txt", :hierarchy => IO.read("#{Rails.root}/vendor/wills_json_structure.json")})
		SaxParser.get_object.delete_and_create_index
		## there should be an index with the required mappings and settings.
		assert_equal (Elasticsearch::Persistence.client.indices.exists? index: "documents"),true
	end

	def test_subclasses_sax_object

		sp = SaxParser.new({:file_path => "#{Rails.root}/vendor/wills.txt", :hierarchy => IO.read("#{Rails.root}/vendor/wills_json_structure.json"), :sax_object_class => "Wills::WillsObject"})
		SaxParser.get_object.delete_and_create_index

		assert_equal (Elasticsearch::Persistence.client.indices.exists? index: "documents"),true

	end


	def test_analyzes_single_object
		
		sp = SaxParser.new({:file_path => "#{Rails.root}/vendor/wills_episcleritis.txt", :hierarchy => IO.read("#{Rails.root}/vendor/wills_json_structure.json"), :sax_object_class => "Wills::WillsObject"})

		SaxParser.get_object.delete_and_create_index

		sp.analyze_file		

		## refresh the index.
		Elasticsearch::Persistence.client.indices.refresh index: "documents"

		## document count 
		count = Elasticsearch::Persistence.client.count index: "documents"
		puts "Count is: #{count}"
		## index should contain one object.
		assert_equal count, 1

	end

	def test_analyzes_two_subsequent_objects

		sp = SaxParser.new({:file_path => "#{Rails.root}/vendor/wills_episcleritis_scleritis.txt", :hierarchy => IO.read("#{Rails.root}/vendor/wills_json_structure.json"), :sax_object_class => "Wills::WillsObject"})

		SaxParser.get_object.delete_and_create_index

		sp.analyze_file		

		## document count 
		count = Elasticsearch::Persistence.client.count index: "documents"
		puts "Count is: #{count}"
		## index should contain one object.
		assert_equal count, 2
	
	end

=end

=begin
	def test_parses_churchill

		sp = SaxParser.new({:file_path => "#{Rails.root}/vendor/churchill_dd.txt", :hierarchy => IO.read("#{Rails.root}/vendor/churchill_json_structure.json"), :sax_object_class => "Churchill::ChurchillObject"})

		SaxParser.get_object.delete_and_create_index

		sp.analyze_file		

		SaxParser.update_workup	

	end
=end


	def test_adds_textbook

		Textbook.add_textbook("#{Rails.root}/vendor/churchill_dd.txt","#{Rails.root}/vendor/churchill_json_structure.json","Churchill::ChurchillObject")

	end


	def test_searches_textbook

		# so we want to aggregate titles and names of diseases
=begin
		GET documents-*/_search
		{
		  "query": {
		    "bool": {
		      "should": [
		        {
		          "match": {
		            "title_text": {
		              "query": "pain",
		              "boost" : 2
		            }
		          }
		        },
		        {
		          "match": {
		            "searchable": "pain"
		          }
		        }
		      ]
		    }
		  },
		  "aggs": {
		    "disease_aggs": {
		      "terms": {
		        "field": "title_text",
		        "order": {
		          "max_score": "desc"
		        }, 
		        "size": 100
		      },
		      "aggs": {
		        "max_score": {
		          "max": {
		            "script": "_score"
		          }
		        },
		        "workup_aggs": {
		          "terms": {
		            "field": "workup",
		            "size": 10
		          }
		        }
		      }
		    }
		  }
		}

=end
	end

end