class InboxController < ApplicationController

  include Mandrill::Rails::WebHookProcessor

  def handle_inbound(event_payload)
    @email = Email.save_inbound_mail(event_payload)
    attaches = event_payload.attachments.presence
    if attaches
      @email.handle_attachments(attaches)
    end
    respond_to do |format|
      if @email
        @email.handle_email
        format.json { render json: @email, status: :created }
      else
        format.json { render json: @email.errors, status: :unprocessable_entity }
      end
    end
  end

end