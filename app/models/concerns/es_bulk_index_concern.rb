module Concerns::EsBulkIndexConcern
  extend ActiveSupport::Concern

  included do
  	cattr_accessor :bulk_items
  	cattr_accessor :total_items_bulked

  	self.bulk_items = []
  	self.total_items_bulked = 0

	##override in implementing model.
	def self.bulk_size
	  1000
	end

	def self.reset_bulk_items
		self.bulk_items = []
	end

	## the total number of items that have been sent to es
	## through the bulk mechanism.
	def self.add_total
		self.total_items_bulked += self.bulk_items.size
	end

	def self.index_bulk_items
		add_total
	  	puts "building bulk items"
	  	bulk_request = bulk_items.map{|c| 
	  		c = 
	  		{
	  			index:  { _index: c.class.index_name, _id: c.id, _type: c.class.document_type, data: c.as_json }
	  		}
	  	}
	  	puts "making bulk call"
	  	resp = gateway.client.bulk body: bulk_request
		puts "completed bulk of #{bulk_size} items."
		puts "total bulked : #{total_items_bulked}"
		puts "#{Time.now.to_i}"
		reset_bulk_items
	end

	## call this method at the end somewhere in the place where you are adding bulk items.
	def self.flush_bulk
		index_bulk_items
	end

	def self.add_bulk_item(item)
		#puts "item time: #{Time.now.to_i}"
	  	if total_items = self.bulk_items.size
	  		bulk_items << item if total_items < self.bulk_size
	  		index_bulk_items if total_items >= self.bulk_size
	  	end
	end

  end

end