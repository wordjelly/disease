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
      true
  end

  ##sets all element attributes to nil
  def reset_element(element_name)
    self.current_tag = nil
    self.current_tag_text = nil
    self.current_tag_attributes_hash = {}
  end

end