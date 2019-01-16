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


	def test_generate_index_mapping_from_hierarchy
		sp = SaxParser.new({:file_path => "#{Rails.root}/vendor/wills.txt", :hierarchy => "#{Rails.root}/vendor/wills_json_structure.json"})
		SaxParser.get_object.delete_and_create_index
		## there should be an index with the required mappings and settings.
		assert_equal (Elasticsearch::Persistence.client.indices.exists? index: SaxParser.get_object.get_index_name),true
	end


	def test_subclasses_sax_object

		sp = SaxParser.new({:file_path => "#{Rails.root}/vendor/wills.txt", :hierarchy => "#{Rails.root}/vendor/wills_json_structure.json", :sax_object_class => "Wills::WillsObject"})
		SaxParser.get_object.delete_and_create_index

		assert_equal (Elasticsearch::Persistence.client.indices.exists? index: SaxParser.get_object.get_index_name),true

	end

	def test_analyzes_single_object
		
		sp = SaxParser.new({:file_path => "#{Rails.root}/vendor/wills_episcleritis.txt", :hierarchy => "#{Rails.root}/vendor/wills_json_structure.json", :sax_object_class => "Wills::WillsObject"})

		SaxParser.get_object.delete_and_create_index

		sp.analyze_file		

		## refresh the index.
		Elasticsearch::Persistence.client.indices.refresh index: SaxParser.get_object.get_index_name

		## document count 
		count = Elasticsearch::Persistence.client.count index: SaxParser.get_object.get_index_name
		puts "-----------------------------------Count is: #{count}"
		count.deep_symbolize_keys!
		puts count.to_s
		puts count[:count]
		puts count["count"]
		## index should contain one object.
		assert_equal count[:count], 1

	end


	def test_analyzes_two_subsequent_objects

		sp = SaxParser.new({:file_path => "#{Rails.root}/vendor/wills_episcleritis_scleritis.txt", :hierarchy => "#{Rails.root}/vendor/wills_json_structure.json", :sax_object_class => "Wills::WillsObject"})

		SaxParser.get_object.delete_and_create_index

		sp.analyze_file		

		## document count 
		## refresh the index.
		Elasticsearch::Persistence.client.indices.refresh index: SaxParser.get_object.get_index_name

		## document count 
		count = Elasticsearch::Persistence.client.count index: SaxParser.get_object.get_index_name
		count.deep_symbolize_keys!
		puts "count is ------------------------- #{count}"
		## index should contain one object.
		assert_equal count[:count],2
	
	end


	#######################################################################
	##
	##
	## NEW SETTING
	##
	##
	#######################################################################b

	def test_adds_allergy_textbook
		Textbook.add_textbook("#{Rails.root}/vendor/oxford_allergy.txt","#{Rails.root}/vendor/oxford_allergy_json_structure.json","Oxford::Allergy")
	end

	def test_adds_dermatology_textbook
		Textbook.add_textbook("#{Rails.root}/vendor/oxford_dermatology.txt",nil,"Oxford::Dermatology","Oxford Dermatology")
	end

	def test_parses_oxford_endocrinology
		Textbook.add_textbook("#{Rails.root}/vendor/oxford_endocrinology.txt",nil,"Oxford::Endocrine","Oxford Manual of Endocrinology")
	end


	def test_parses_oxford_endocrinology
		Textbook.add_textbook("#{Rails.root}/vendor/oxford_ent.txt",nil,"Oxford::Ent","Oxford Manual of OtoRhinoLaryngyology")
	end

	def test_adds_general_practise_textbook
		Textbook.add_textbook("#{Rails.root}/vendor/oxford_general_practise.txt",nil,"Oxford::GeneralPractise", "Oxford Manual of General Practise")
	end

	def test_adds_geriatrics_textbook
		Textbook.add_textbook("#{Rails.root}/vendor/oxford_geriatrics.txt",nil,"Oxford::Geriatrics","Oxford Manual of Geriatrics")
	end

	def test_adds_nephrology_textbook
		Textbook.add_textbook("#{Rails.root}/vendor/oxford_nephrology.txt",nil,"Oxford::Nephrology","Oxford Manual of Nephrology")
	end

	def test_adds_neurology_textbook
		Textbook.add_textbook("#{Rails.root}/vendor/oxford_neurology.txt",nil,"Oxford::Neurology","Oxford Manual of Neurology")
	end

	def test_adds_respiratory_medicine_textbook
		Textbook.add_textbook("#{Rails.root}/vendor/oxford_respiratory_medicine.txt",nil,"Oxford::Respiratory","Oxford Manual of Respiratory medicine")
	end

	def test_adds_rheumatology_textbook
		Textbook.add_textbook("#{Rails.root}/vendor/oxford_rheumatology.txt",nil,"Oxford::Rheumatology","Oxford Manual of Rheumatology")
	end

	def test_adds_surgery_textbook
		Textbook.add_textbook("#{Rails.root}/vendor/oxford_surgery.txt",nil,"Oxford::Surgery","Oxford Manual of Surgery")
	end

	def test_adds_tropical_medicine_textbook
		Textbook.add_textbook("#{Rails.root}/vendor/oxford_tropical_medicine.txt",nil,"Oxford::TropicalMedicine","Oxford Manual of Tropical Medicine")
	end

	def test_parses_evidence_based_gynecology
		Textbook.add_textbook("#{Rails.root}/vendor/gynecology_evidence_based_algorithms.txt","#{Rails.root}/vendor/gyn_evi_algo.json","Obstetrics::EvidenceObject",nil)
	end


	def test_paediatric_algorithms
		Textbook.add_textbook("#{Rails.root}/vendor/paediatric_algorithms.txt","#{Rails.root}/vendor/paediatric_algo.json","Paediatric::Algorithm",nil)
	end

	def test_adds_churchill

		Textbook.add_textbook("#{Rails.root}/vendor/churchill_dd.txt","#{Rails.root}/vendor/churchill_json_structure.json","Churchill::ChurchillObject",nil)

	end


	def test_adds_obstetrics_algorithms

		Textbook.add_textbook("#{Rails.root}/vendor/obstetric_screening_algorithms.txt","#{Rails.root}/vendor/obs_json_structure.json","Obstetrics::ObsObject",nil)		

	end

	
	def test_adds_wills_eye_manual

		Textbook.add_textbook("#{Rails.root}/vendor/wills.txt","#{Rails.root}/vendor/wills_json_structure.json","Wills::WillsObject",nil)

	end


	def test_adds_dewhurst
		Textbook.add_textbook("#{Rails.root}/vendor/dewhurst.txt","#{Rails.root}/vendor/dewhurst_json_structure.json","Obstetrics::DewhurstObject",nil)		
	end


end