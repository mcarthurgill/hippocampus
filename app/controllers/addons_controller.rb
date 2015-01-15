class AddonsController < ApplicationController
  def api_endpoint
    if Addon.for_addon_name_and_token(params[:addon], params[:token])
      Item.create_from_api_endpoint(params)  
      render :nothing => true, :status => 200
    else 
      render :nothing => true, status => 401
    end
    
  end
end
