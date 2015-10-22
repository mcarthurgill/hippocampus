class ApplicationController < ActionController::Base 
  protect_from_forgery

  include Formatting

  # def authenticate_request
  #   #authenticate requests from our addons
  #   if logged_in?
  #     @current_user = current_user
  #   else
  #     authenticate_or_request_with_http_basic do |username, password|
  #       username == ENV["HTTP_USERNAME"] && password == ENV["HTTP_PASSWORD"]
  #     end
  #   end
  # end
  
  def mobile?
    @mobile = request.user_agent =~ /Mobile/
  end

  def logged_in?
    current_user
  end
  helper_method :logged_in?

  def redirect_if_not_logged_in
    if !logged_in?
      redirect_to root_path
      return true
    end
  end

  def redirect_if_not_authorized uid
    if !logged_in? || current_user.id.to_i != uid.to_i
      redirect_to root_path
      return true
    end
  end

  def current_user
    @current_user ||= User.find(cookies[:user_id]) if cookies[:user_id]
    return @current_user
  end
  helper_method :current_user

  def redirect_logged_in_user
    if logged_in?
      redirect_to user_path(current_user)
      return
    end
  end
end

