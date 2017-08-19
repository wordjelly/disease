class Yielder < ::Ox::Sax

  	def initialize(block,item_class)
  		@yield_to = block
  		@item_class = item_class
  		@item = nil
  	end
    
    def start_element(name)
        @item = @item_class.new if name =~ /#{@item_class.Root}/
        @item.current_tag = name
    end

    def attr(name,value)
    	
    end

    ##the text of the current tag.
    def text(value)
    	@item.current_tag_text = value
    	@item.print_tag_with_text
    end

    def end_element(name)
    	
    end

end