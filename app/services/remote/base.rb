module Remote
  class Base
    include ActiveModel::Model
    attr_accessor :id, :created_at, :updated_at

    class << self
      def resource_path
        raise 'not implemented'
      end

      def resource_ttl
        86400 # override in subclasses if necessary
      end

      # Add * as a temporary measure so that we can easily see in the UI
      # that it is using the API to get data, not the DB.
      #
      def all
        get.map { |h| new(h.merge(name: h['name'] += ' *')) }
      end

      def find(id)
        all.detect { |m| m.id == id }
      end

      private

      # TODO 1: decide which http library to use (RestClient, Faraday, Typhoeus...)
      # TODO 2: sort out timeouts at the http library level
      # TODO 3: extract all http related code to a separated class and inject it
      #
      def get
        response = Caching::ApiRequest.cache(endpoint.url, ttl: resource_ttl) do
          endpoint.get { |response, _request, _result| response }
        end
        JSON.parse(response)
      end

      def endpoint
        RestClient::Resource.new([Settings.remote_api_url, resource_path].join('/') + query_params)
      end

      def query_params
        '?' + {api_key: Settings.remote_api_key}.to_query
      end
    end
  end
end
