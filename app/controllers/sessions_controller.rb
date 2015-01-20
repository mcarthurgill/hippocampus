class SessionsController < ApplicationController

  def new
    redirect_logged_in_user
  end

  def passcode
    @user = User.with_or_initialize_with_phone_number(params[:phone])
    @user.update_and_send_passcode 
    respond_to do |format|
      format.html
      format.json { render json: { :success => 'success' } }
    end
  end

  def create
    @user = User.find_by_phone(format_phone(params[:phone], "1"))
    if @user && @user.correct_passcode?(params[:passcode])
      cookies[:user_id] = { value: @user.id.to_s, expires: 10.years.from_now }
      respond_to do |format|
        format.html do 
          redirect_to user_path(@user)
          return
        end
        format.json { render json: { :success => 'success', :user => @user } }
      end
    end
    respond_to do |format|
      format.html do 
        redirect_to login_path, :notice => "You entered the wrong passcode."
        return
      end
      format.json { render json: { :success => 'failed' } }
    end
  end

  def destroy
    cookies.delete :user_id
    redirect_to root_path, :notice => "You've been logged out successfully."
  end

end
