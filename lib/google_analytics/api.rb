require 'rest_client'

module GoogleAnalytics
  class API
    def self.event(category, action, label = nil, client_id = fallback_client_id)
      return if tracker_id.blank?
      params = { v: version, tid: tracker_id, cid: client_id, t: 'event', ec: category, ea: action }
      params[:el] = label if label.present?
      begin
        RestClient.get(endpoint, params:, timeout: 4, open_timeout: 4)
        true
      rescue RestClient::Exception
        false
      end
    end

    def self.tracker_id
      Settings.google_analytics.tracker_id
    end

    def self.version
      Settings.google_analytics.version
    end

    def self.endpoint
      Settings.google_analytics.endpoint
    end

    def self.fallback_client_id
      Settings.google_analytics.fallback_client_id.to_s
    end
  end
end
