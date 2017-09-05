=begin
How to implement and use this module together with the ox sax parser.
=======

Create a model

A]define a class method called 

def self.item_element
  "whatever"
end

return the name of the root tag of the items that the xml document defines.

the model should be designed to hold whatever attributes of this item that you are interested in.

B]implement gather_element instance method in the model
eg:

def gather_element(element_name)
    if current_tag.to_s == "ArticleTitle"
      whatever.
    end
end

this gather element is called everytime we have all the attributes and text of an element ready.
----------------------------------

C]call the parser by doing the following(inside the model itsel)

def self.parse
  proc = Proc.new { |item|}
  handler = Yielder.new(proc,model_class)
  io = IO.read(file_path)
  Ox.sax_parse(handler, io)
end


D]Please use the yielder class from this project/lib, for everything to work properly.

=end
module Concerns::XmlConcern
  extend ActiveSupport::Concern

  included do
  	attr_accessor :current_tag
	  attr_accessor :current_tag_text
    attr_accessor :current_tag_attributes_hash
  end

  def self.item_element
  	nil
  end

  
  ## convenience method called by yielder when we have all the data of the element, so you can do whatever you want with the element here.
  def gather_element(element_name)
      
  end

  ##sets all element attributes to nil
  def reset_element(element_name)
    self.current_tag = nil
    self.current_tag_text = nil
    self.current_tag_attributes_hash = {}
  end

end