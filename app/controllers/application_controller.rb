class ApplicationController < ActionController::Base 
  protect_from_forgery

  include Formatting
  
  def mobile?
    @mobile = request.user_agent =~ /Mobile/
  end

  def logged_in?
    cookies[:user_id] && cookies[:user_id].length > 0 && User.find(cookies[:user_id])
  end
  helper_method :logged_in?

  def current_user
    if logged_in?
      @current_user = User.find(cookies[:user_id])
      return @current_user
    end
    return nil
  end
  helper_method :current_user

  def redirect_logged_in_user
    if logged_in?
      redirect_to user_path(current_user)
      return
    end
  end
end
