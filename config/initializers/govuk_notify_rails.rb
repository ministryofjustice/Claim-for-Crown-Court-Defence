ActionMailer::Base.add_delivery_method :govuk_notify, GovukNotifyRails::Delivery,
  service_id: ENV['GOVUK_NOTIFY_SERVICE_ID'],
  secret_key: ENV['GOVUK_NOTIFY_API_SECRET']
