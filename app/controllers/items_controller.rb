class ItemsController < ApplicationController

  # POST /items
  # POST /items.json
  def create
    
    @item = Item.new(params[:item])

    respond_to do |format|
      if @item.save
        format.json { render json: @item, status: :created, location: @item }
      else
        format.json { render json: @item.errors, status: :unprocessable_entity }
      end
    end

  end

  # PUT /items/1
  # PUT /items/1.json
  def update
    @item = Item.find(params[:id])

    respond_to do |format|
      if @item.update_attributes(params[:item])
        format.json { head :no_content }
      else
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
