class ItemsController < ApplicationController
  # # GET /items
  # # GET /items.json
  # def index
  #   @items = Item.all

  #   respond_to do |format|
  #     format.html # index.html.erb
  #     format.json { render json: @items }
  #   end
  # end

  # # GET /items/1
  # # GET /items/1.json
  # def show
  #   @item = Item.find(params[:id])

  #   respond_to do |format|
  #     format.html # show.html.erb
  #     format.json { render json: @item }
  #   end
  # end

  # # GET /items/new
  # # GET /items/new.json
  # def new
  #   @item = Item.new

  #   respond_to do |format|
  #     format.html # new.html.erb
  #     format.json { render json: @item }
  #   end
  # end

  # # GET /items/1/edit
  # def edit
  #   @item = Item.find(params[:id])
  # end

  # POST /items
  # POST /items.json
  def create
    @item = Item.new(params[:item])

    if params[:Body] && params[:Body].length > 0 && params[:From] && params[:From].length > 0 #from twilio
      @item.set_attrs_from_twilio(params[:Body], format_phone(params[:From], "1"), "outstanding")
    end

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
