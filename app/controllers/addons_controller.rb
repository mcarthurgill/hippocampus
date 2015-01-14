class AddonsController < ApplicationController
  def show
    response = Addon.send_request_for_user_and_addon_id(current_user, params[:id])
    if response.nil? 
      redirect_to root_path, :notice => "Sorry that didn't work."
      return
    end
    render :text => response.body, :layout => "application"
  end
end
