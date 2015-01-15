class AddonsController < ApplicationController
  def api_endpoint
    Item.create(:message => params[:query][:message], :user_id => 1)
    render :nothing => true, :status => 200
  end
end
