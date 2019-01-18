require 'test_helper'

class TextbooksControllerTest < ActionController::TestCase

	test "searches" do 
		get textbooks_url, params: {query: "pain"}
		puts @response.body
	end

end