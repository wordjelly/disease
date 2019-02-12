require 'test_helper'

class AdityaTest < ActiveSupport::TestCase

## that way this can be made to work out.
## so the suggestions will be built on that.
## build_suggestions is updated,
## and let me see how long it takes to return anything.

=begin
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
=end

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