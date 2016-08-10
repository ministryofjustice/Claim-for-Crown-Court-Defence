# Extract to gem
#
require 'notifications/client'

class GovukNotifyDelivery
  attr_accessor :settings

  def initialize(settings)
    self.settings = settings
  end

  def deliver!(message)
    notify_client.send_email(payload_for(message))
  end


  private

  def service_id
    settings[:service_id]
  end

  def secret_key
    settings[:secret_key]
  end

  def payload_for(message)
    {
      to: message.to.first,
      template: message.govuk_notify_template,
      personalisation: message.govuk_notify_personalisation
    }.to_json
  end

  def notify_client
    @notify_client ||= Notifications::Client.new(service_id, secret_key)
  end
end
