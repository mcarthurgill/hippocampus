class AddonsController < ApplicationController
  def api_endpoint
    Item.create(:message => params[:query][:message] + "1", :user_id => 1)
    Item.create(:message => params[:message] + "2", :user_id => 1)
    Item.create(:message => params.to_json, :user_id => 1)
    render :nothing => true, :status => 200
  end
end
