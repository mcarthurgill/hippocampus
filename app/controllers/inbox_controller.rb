class InboxController < ApplicationController
  include Mandrill::Rails::WebHookProcessor
  ignore_unhandled_events!

  def handle_inbound(event_payload)
    @email = Email.save_inbound_mail(event_payload)
    respond_to do |format|
      if @email
        # @email.create_item
        format.json { render json: @email, status: :created }
      else
        format.json { render json: @email.errors, status: :unprocessable_entity }
      end
    end
  end

end