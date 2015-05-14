class InboxController < ApplicationController
  include Mandrill::Rails::WebHookProcessor
  ignore_unhandled_events!

  def handle_inbound(event_payload)
    Email.save_inbound_mail(event_payload)
  end

end