class Yielder < ::Ox::Sax

  	def initialize(block,item_class)
  		@yield_to = block
  		@item_class = item_class
  		@item = nil
  	end
    
    def start_element(name)
       
        @item.gather_element(name) if @item
        if name =~ /#{@item_class.item_element}/
          if @item
            puts "this is the previous item to be saved."
            puts @item.attributes.to_s
            ##call save here.
            gets.chomp
          end
          @item = @item_class.new
        else
          @item.reset_element(name) if @item
        end
        @item.current_tag = name if @item
    end

    def attr(name,value)
      if @item
        @item.current_tag_attributes_hash ||= {}
        @item.current_tag_attributes_hash[name] = value
      end      
    end

    ##the text of the current tag.
    def text(value)
    	if @item
        @item.current_tag_text = value
      end      
    end


    ##this is necessary to call for the last element, because it 
    ##will never be gathered otherwise.
    def end_element(name)
      if ((@item) && (name == @item.current_tag))
        @item.gather_element(name)
        @item.reset_element(name)
      end
    end

end