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

  before_filter :set_cache_headers

  private

  def set_cache_headers
    response.headers["Cache-Control"] = "no-cache, no-store, max-age=0, must-revalidate"
    response.headers["Pragma"] = "no-cache"
    response.headers["Expires"] = "Fri, 01 Jan 1990 00:00:00 GMT"
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

  def get_most_recent_buckets lim=10
    @recent_buckets = current_user.buckets.order("updated_at DESC").limit(lim) if current_user
  end

  def formatted_date date
    return date ? date.strftime("%m/%d/%y") : nil
  end
  helper_method :formatted_date

  def long_formatted_date date
    date = date.in_time_zone(current_user.time_zone) if date
    return date ? date.strftime("%A %B %d, %Y") : nil
  end
  helper_method :long_formatted_date

  def long_formatted_time date
    date = date.in_time_zone(current_user.time_zone) if date
    return date ? date.strftime("%I:%M%p %Z") : nil
  end
  helper_method :long_formatted_time

  def buckets_active?
    @active == "buckets"
  end
  helper_method :buckets_active?

  def thoughts_active?
    @active == "thoughts"
  end
  helper_method :thoughts_active?

  def nudges_active?
    @active == "nudges"
  end
  helper_method :nudges_active?

  def active_thought_classes
    thoughts_active? ? 'thoughts active' : 'thoughts'
  end
  helper_method :active_thought_classes

  def active_bucket_classes
    buckets_active? ? 'buckets active' : 'buckets'
  end
  helper_method :active_bucket_classes

  def active_nudge_classes
    nudges_active? ? 'nudges active' : 'nudges'
  end
  helper_method :active_nudge_classes
end

