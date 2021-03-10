# Sets the analytics engine data layer adapter. Currently it supports:
#
#   :ga  -> Google Analytics
#   :gtm -> Google Tag Manager
#
GoogleAnalytics::DataTracking.active = true
GoogleAnalytics::DataTracking.adapter = ENV['GTM_TRACKER_ID'].present? ? :gtm : :ga
