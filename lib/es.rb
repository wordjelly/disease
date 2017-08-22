module Es
	def self.index_destroy
		begin
			del_response = self.gateway.client.indices.delete index: self.class.name.pluralize
			puts del_response
		rescue => e
			puts e.to_s
		end
	end

	def index_rebuild
	end
end