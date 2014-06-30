class SmsController < ApplicationController

  # POST /sms
  # POST /sms.json
  def create
    @sm = Sm.new(params)

    respond_to do |format|
      if @sm.save
        @sm.create_item
        format.json { render json: @sm, status: :created }
      else
        format.json { render json: @sm.errors, status: :unprocessable_entity }
      end
    end
  end

end
