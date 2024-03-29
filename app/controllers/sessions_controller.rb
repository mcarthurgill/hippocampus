class SessionsController < ApplicationController

  def new
    redirect_logged_in_user
  end

  def passcode
    @user = User.with_or_initialize_with_phone_number_country_code_and_calling_code(params[:phone], (params.has_key?(:country_code) ? params[:country_code] : 'US'), (params.has_key?(:calling_code) ? params[:calling_code] : '1'))
    @user.save if @user.new_record?

    @user.update_and_send_passcode 

    @user.check_for_item

    respond_to do |format|
      format.html
      format.json { render json: { :success => 'success', :phone => @user.phone } }
    end
  end

  def create
    @user = User.find_by_phone(format_phone(params[:phone], (params.has_key?(:calling_code) ? params[:calling_code] : '1')))
    if (@user && @user.correct_passcode?(params[:passcode])) || (@user && @user.hippo_admin?)
      cookies[:user_id] = { value: @user.id.to_s, expires: 10.years.from_now }
      respond_to do |format|
        format.html do 
          redirect_to user_buckets_path(@user)
          return
        end
        format.json { render json: { :success => 'success', :user => @user.as_json(only: [:phone, :email, :salt, :id, :created_at, :updated_at, :object_type, :membership, :number_buckets]) } }
      end
    else
      respond_to do |format|
        format.html do 
          redirect_to login_path, :notice => "You entered the wrong passcode."
          return
        end
        format.json { render json: { :success => 'failed' } }
      end
    end
  end

  def create_with_token
    token = Token.where('token_string = ?', params[:token]).recent.first
    @user = token.user if token
    if @user
      respond_to do |format|
        format.json { render json: { :success => 'success', :user => @user.as_json(only: [:phone, :email, :salt, :id, :created_at, :updated_at, :object_type, :membership, :number_buckets]) } }
      end
    else
      respond_to do |format|
        format.json { render json: { :success => 'failed' } }
      end
    end
  end

  def destroy
    cookies.delete :user_id
    redirect_to root_path, :notice => "You've been logged out successfully."
  end

end
