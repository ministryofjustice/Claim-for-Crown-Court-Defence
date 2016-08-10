# Extract to gem, except configuration
#
require_relative '../../lib/govuk_notify_delivery'

# TODO: ask platforms to expose these env variables, once we have them
#
ActionMailer::Base.add_delivery_method :govuk_notify, GovukNotifyDelivery,
  service_id: ENV['GOVUK_NOTIFY_SERVICE_ID'],
  secret_key: ENV['GOVUK_NOTIFY_API_SECRET']

module Mail
  class Message
    attr_accessor :govuk_notify_template
    attr_accessor :govuk_notify_personalisation
  end
end
