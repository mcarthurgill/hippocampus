class PagesController < ApplicationController


  def search

    # redirect_if_not_logged_in ? return : nil

    @active = 'search'

    @results = nil
    if params.has_key?(:t) && params[:t].strip.length > 0
      user_id = current_user ? current_user.id : params[:user_id]
      client = Swiftype::Client.new
      # get users + topics, return as one array
      @results = client.search('engine', params[:t], {:document_types => ['items','buckets'], :search_fields => { 'items' => ['text^4','buckets_string'], 'buckets' => ['first_name'] }, :filters => { 'items' => {'available_to' => [user_id] }, 'buckets' => {'available_to' => [user_id] } } } )
    end

    puts @results

    respond_to do |format|
      format.html
      format.json { render json: { :buckets => @results.records['buckets'], :items => @results.records['items'], :term => params[:t] } }
    end

  end



  def info
  end
  
end
