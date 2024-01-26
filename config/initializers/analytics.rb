# Sets the analytics engine data layer adapter. Currently it supports:
#
#   :ga  -> Google Analytics
#   :gtm -> Google Tag Manager
#
Rails.application.reloader.to_prepare do
  GoogleAnalytics::DataTracking.adapter = ENV['GTM_TRACKER_ID'].present? ? :gtm : :ga
end
