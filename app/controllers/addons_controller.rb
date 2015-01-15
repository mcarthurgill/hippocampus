class AddonsController < ApplicationController
  def api_endpoint
    Item.create(:message => params[:message], :user_id => 1)
    render :nothing => true, :status => 200, :content_type => 'text/html'
  end
end
