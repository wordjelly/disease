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

=begin
	def test_adds_churchill

		Textbook.add_textbook("#{Rails.root}/vendor/churchill_dd.txt","#{Rails.root}/vendor/churchill_json_structure.json","Churchill::ChurchillObject")

	end


	def test_adds_obstetrics_algorithms

		Textbook.add_textbook("#{Rails.root}/vendor/obstetric_screening_algorithms.txt","#{Rails.root}/vendor/obs_json_structure.json","Obstetrics::ObsObject")		

	end

	
	def test_adds_wills_eye_manual

		Textbook.add_textbook("#{Rails.root}/vendor/wills.txt","#{Rails.root}/vendor/wills_json_structure.json","Wills::WillsObject")

	end


	def test_adds_dewhurst
		Textbook.add_textbook("#{Rails.root}/vendor/dewhurst.txt","#{Rails.root}/vendor/dewhurst_json_structure.json","Obstetrics::DewhurstObject")		
	end
=end

=begin
	def test_parses_table_of_contents_oxford_endocrine

		Oxford::Oxford.parse_table_of_contents("#{Rails.root}/vendor/oxford_endocrinology_contents.txt","oxford_endo_topics")

	end
=end

=begin
	def test_parses_table_of_contents_oxford_ent

		Oxford::Oxford.parse_table_of_contents("#{Rails.root}/vendor/oxford_ent_contents.txt","oxford_ent_topics")

	end
=end

=begin
	def test_parses_oxford_endocrinology
		Textbook.add_textbook("#{Rails.root}/vendor/oxford_endocrinology.txt","#{Rails.root}/vendor/oxford_endo_json_structure.json","Oxford::Endocrine")
	end
=end

=begin
	def test_parses_oxford_ent
		Textbook.add_textbook("#{Rails.root}/vendor/oxford_ent.txt","#{Rails.root}/vendor/oxford_ent_json_structure.json","Oxford::Ent")
	end
=end

=begin
	def test_parses_evidence_based_gynecology
		Textbook.add_textbook("#{Rails.root}/vendor/gynecology_evidence_based_algorithms.txt","#{Rails.root}/vendor/gyn_evi_algo.json","Obstetrics::EvidenceObject")
	end
=end
	
	def test_paediatric_algorithms
		Textbook.add_textbook("#{Rails.root}/vendor/paediatric_algorithms.txt","#{Rails.root}/vendor/paediatric_algo.json","Paediatric::Algorithm")
	end

end