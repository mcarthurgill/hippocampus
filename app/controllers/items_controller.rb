class ItemsController < ApplicationController

  def show
    @item = Item.find(params[:id])

    respond_to do |format|
      format.html
      format.json
    end
  end


  # POST /items
  # POST /items.json
  def create
    
    @item = Item.new(params[:item])

    respond_to do |format|
      if @item.save
        format.html { redirect_to item_path(@item), :notice => "Woohoo! It worked." }
        format.json { render json: @item, status: :created, location: @item }
      else
        format.html { redirect_to new_item_path, :notice => "Whoops. Try again." }
        format.json { render json: @item.errors, status: :unprocessable_entity }
      end
    end

  end


  def new
    @item = Item.new
    @options_for_buckets = current_user.formatted_buckets_options

    respond_to do |format|
      format.html 
      format.json { render json: @item }
    end
  end


  def edit
    @item = Item.find(params[:id])

    @options_for_buckets = current_user.formatted_buckets_options

    respond_to do |format|
      format.html
      format.json { head :no_content }
    end
  end
  

  def assign
    @item = Item.find(params[:id])
    @user = current_user

    @options_for_buckets = @item.user.formatted_buckets_options

    respond_to do |format|
      format.html
      format.json { head :no_content }
    end
  end

  # PUT /items/1
  # PUT /items/1.json
  def update
    @item = Item.find(params[:id])

    respond_to do |format|
      if @item.update_attributes(params[:item])
        @item.update_outstanding
        format.html { redirect_to item_path(@item), :notice => "That worked!" }
        format.json { head :no_content }
      else
        format.html { redirect_to edit_item_path(@item), :notice => "Sorry that didn't work" }
        format.json { render json: @item.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /items/1
  # DELETE /items/1.json
  def destroy
    @item = Item.find(params[:id])
    @item.destroy

    respond_to do |format|
      format.json { head :no_content }
    end
  end

end
