# Sets the analytics engine data layer adapter. Currently it supports:
#
#   :ga  -> Google Analytics
#   :gtm -> Google Tag Manager
#
Rails.application.reloader.to_prepare do
  GoogleAnalytics::DataTracking.adapter = :ga
end
