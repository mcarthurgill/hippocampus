class OutsideController < ApplicationController

  def splash
  end
  
  def privacy
  end

  def gifts
    @u = User.find_by_salt(params[:code])
    @address = Address.new
  end

end
