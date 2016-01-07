class AddressesController < ApplicationController
  def create
    Address.create_with_params(params[:address])
    redirect_to gifts_path
  end
end
