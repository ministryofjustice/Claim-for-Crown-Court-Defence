require 'court_data_adaptor/oauth_adapter'

module CourtDataAdaptor
  module Resource
    class Base < JsonApiClient::Resource
      self.connection_class = CourtDataAdaptor::OauthAdapter
    end
  end
end
