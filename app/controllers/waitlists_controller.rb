class WaitlistsController < ApplicationController
  # GET /waitlists
  # GET /waitlists.json
  def index
    @waitlists = Waitlist.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @waitlists }
    end
  end

  # GET /waitlists/1
  # GET /waitlists/1.json
  def show
    @waitlist = Waitlist.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @waitlist }
    end
  end

  # GET /waitlists/new
  # GET /waitlists/new.json
  def new
    @waitlist = Waitlist.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @waitlist }
    end
  end

  # GET /waitlists/1/edit
  def edit
    @waitlist = Waitlist.find(params[:id])
  end

  # POST /waitlists
  # POST /waitlists.json
  def create
    @waitlist = Waitlist.new(params[:waitlist])

    respond_to do |format|
      if @waitlist.save
        format.html { redirect_to @waitlist, notice: 'Waitlist was successfully created.' }
        format.json { render json: @waitlist, status: :created, location: @waitlist }
        format.js
      else
        format.html { render action: "new" }
        format.json { render json: @waitlist.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /waitlists/1
  # PUT /waitlists/1.json
  def update
    @waitlist = Waitlist.find(params[:id])

    respond_to do |format|
      if @waitlist.update_attributes(params[:waitlist])
        format.html { redirect_to @waitlist, notice: 'Waitlist was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @waitlist.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /waitlists/1
  # DELETE /waitlists/1.json
  def destroy
    @waitlist = Waitlist.find(params[:id])
    @waitlist.destroy

    respond_to do |format|
      format.html { redirect_to waitlists_url }
      format.json { head :no_content }
    end
  end
end
