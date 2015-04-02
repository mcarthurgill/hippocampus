class SmsController < ApplicationController

  # POST /sms
  # POST /sms.json
  def create
    @sm = Sm.new(params)
    @sm.add_media_if_present(params)

    respond_to do |format|
      if @sm.initial_signup_text?
        User.with_phone_number(@sm.From)
      elsif @sm.save
        @sm.create_item
        format.json { render json: @sm, status: :created }
      else
        format.json { render json: @sm.errors, status: :unprocessable_entity }
      end
    end
  end
end
