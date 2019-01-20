require 'test_helper'

class AdityaTest < ActiveSupport::TestCase

	test "creates index" do 
		resp = Aditya::Aditya.create_index(Elasticsearch::Persistence.client)
		assert_equal true, resp["acknowledged"]
	end


	test "populates index" do 
		resp = Aditya::Aditya.create_index(Elasticsearch::Persistence.client)
		assert_equal true, resp["acknowledged"]
		Aditya::Aditya.populate_index
		Aditya::Aditya.refresh_index(Elasticsearch::Persistence.client)
		count = Elasticsearch::Persistence.client.count index: Aditya::Aditya::INDEX_NAME
		count.deep_symbolize_keys!
		assert_equal count[:count], 8271
	end


	test "creates and populates index and updates to remote" do 
		resp = Aditya::Aditya.create_index(Elasticsearch::Persistence.client)
		assert_equal true, resp["acknowledged"]
		Aditya::Aditya.populate_index
		Aditya::Aditya.refresh_index(Elasticsearch::Persistence.client)
		count = Elasticsearch::Persistence.client.count index: Aditya::Aditya::INDEX_NAME
		count.deep_symbolize_keys!
		assert_equal count[:count], 8271
		Aditya::Aditya.update_to_remote
	end


end