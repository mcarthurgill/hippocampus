class AddonsController < ApplicationController
  def api_endpoint
    addon = Addon.for_addon_name_and_token(params[:addon], params[:addon_token])
    respond_to do |format|
      if addon
        resp = addon.determine_endpoint_action(params)
        if resp
          format.json { render json: resp.to_json, :status => 200 }  
        else
          format.json { render :nothing => true, :status => 401 }
        end
      else 
        format.json { render :nothing => true, :status => 401 }
      end
    end
  end
end


