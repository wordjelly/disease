class TextbooksController < ApplicationController
	respond_to :html, :json, :js
	def index
		
	end

	def search
		@search_hits =  Textbook.search(permitted_params[:query])	
		respond_to do |format|
			format.json{render json: {results: @search_hits}}
			format.html{render :index}
		end	
	end

	def permitted_params
		params.permit(:query)
	end
end