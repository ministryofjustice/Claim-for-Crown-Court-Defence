require 'court_data_adapter/oauth_adapter'

module CourtDataAdapter
  module Resource
    class Base < JsonApiClient::Resource
      self.connection_class = CourtDataAdapter::OauthAdapter
    end
  end
end
