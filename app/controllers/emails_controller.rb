class EmailsController < ApplicationController
  
  # POST /emails
  # POST /emails.json
  def create
    # @email = Email.new(params)
    @email = Email.new

    respond_to do |format|
      if @email.save
        # @email.create_item
        format.json { render json: @email, status: :created }
      else
        format.json { render json: @email.errors, status: :unprocessable_entity }
      end
    end
  end

end
