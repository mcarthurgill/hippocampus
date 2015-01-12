class UsersController < ApplicationController
  # GET /users/1
  # GET /users/1.json
  def show
    @user = User.find(params[:id])

    respond_to do |format|
      format.html
      format.json { render json: @user }
    end
  end

  # GET /users/1/items
  # GET /users/1/items.json
  def items
    @user = User.find(params[:id])

    respond_to do |format|
      format.json { render json: @user.items.above(params[:above]) }
    end
  end

  # GET /users/1/buckets
  # GET /users/1/buckets.json
  def buckets
    @user = User.find(params[:id])

    respond_to do |format|
      format.json { render json: @user.buckets.above(params[:above]) }
    end
  end

  # POST /users
  # POST /users.json
  def create

    @user = User.with_or_initialize_with_phone_number(params[:user][:phone])

    respond_to do |format|
      if @user.save
        format.json { render json: @user, status: :created, location: @user }
      else
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user = User.find(params[:id])
    @user.destroy

    respond_to do |format|
      format.json { head :no_content }
    end
  end

end
