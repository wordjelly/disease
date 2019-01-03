require 'test_helper'

class SaxObjectTest < ActiveSupport::TestCase

	def test_initializes_sax_object_without_args

		so = SaxObject.new

	end

	def test_initializes_sax_object_with_args


		args = {:name => "test", :regex => "abc"}
		
		so = SaxObject.new(args)
		
		assert_equal so.name, "test" 
		
		assert_equal so.regex, "abc"

	end

	def test_initializes_sax_object_with_hierarchy

		args = {
			:name => "test",
			:regex => "abc",
			:components => [
				{
					:name => "c1",
					:regex => "abc"
				},
				{
					:name => "c2",
					:regex => "abc"
				}
			]
 		}

 		so = SaxObject.new(args)
 		assert_equal so.components.size,2
 		assert_equal so.components.first.name, "c1"
 		assert_equal so.components.last.name, "c2"

	end

	

end