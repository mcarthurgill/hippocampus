class AddonsController < ApplicationController
  def api_endpoint
    respond_to do |format|
      if Addon.for_addon_name_and_token(params[:addon], params[:addon_token]) && i = Item.create_from_api_endpoint(params)  
        format.html { render bucket_id: i.bucket_id }
      else 
        format.html { render :nothing => true, :status => 401 )
      end
    end
  end
end
