class ApplicationController < ActionController::Base
  
  protect_from_forgery
  before_filter :login_user

  def login_user
    @user = User.find(2)
  end
  
  def format_phone(number, country_code)
    strip_whitespace!(number)
    prepare_country_code!(country_code)
    if number && number.first == "+"
      return strip_non_numeric!(number)
    elsif country_code && country_code.length > 0
      strip_non_numeric!(number)
      if number_has_country_code?(number, country_code)
        remove_country_code!(number, country_code)
      end
      remove_leading_zeros!(number)
      return add_country_code(number, country_code)
    end
  end

  def strip_whitespace!(number)
    number.gsub!(/\s+/, "")
  end

  def strip_non_numeric!(number)
    number.gsub!(/\D/, '')
  end

  def number_has_country_code?(number, country_code)
    number.slice(0...country_code.length) == country_code
  end

  def remove_country_code!(number, country_code)
    number.slice!(0...country_code.length)
  end

  def remove_leading_zeros!(number)
    number.sub!(/^0+/, "")
  end

  def add_country_code(number, country_code)
    number.prepend(country_code)
  end

  def prepare_country_code!(country_code)
    strip_whitespace!(country_code)
    strip_non_numeric!(country_code)
    return country_code
  end


  def logged_in?
    # cookies[:user_id] && cookies[:user_id].length > 0 && User.find(cookies[:user_id])
    true
  end
  helper_method :logged_in?
end
