class PagesController < ApplicationController


  def search
    @active = 'search'

    @results = nil
    if params.has_key?(:t) && params[:t].strip.length > 0
      client = Swiftype::Client.new
      # get users + topics, return as one array
      @results = client.search('engine', params[:t], {:document_types => ['items','buckets'], :search_fields => { 'items' => ['message','buckets_string'], 'buckets' => ['first_name'] }, :filters => { 'items' => {'user_id' => current_user.id}, 'buckets' => {'user_id' => current_user.id} } } )
    end

    puts @results

  end



  def info
  end
  
end
