class DeviceTokensController < ApplicationController
  # POST /device_tokens
  # POST /device_tokens.json
  def create
    @device_token = DeviceToken.find_or_initialize_by_ios_device_token(params[:device_token][:ios_device_token])
    @device_token.assign_attributes(params[:device_token])

    respond_to do |format|
      if @device_token.save
        format.json { render json: @device_token.as_json }
      else
        format.json { render json: @device_token.errors, status: :unprocessable_entity }
      end
    end
    
  end
end
