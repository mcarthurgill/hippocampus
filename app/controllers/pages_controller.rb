class PagesController < ApplicationController


  def search

    @active = 'search'

    @results = nil

    respond_to do |format|
      format.html
      format.json { render json: { :buckets => [], :items => [], :term => params[:t] } }
    end

  end



  def info
  end
  
end
