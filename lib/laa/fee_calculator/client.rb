require 'faraday'

module LAA
  module FeeCalculator
    class Client
      extend Forwardable

      attr_reader :host, :options
      def_delegators :connection, :get, :post, :put, :patch, :delete

      def initialize(host, options = {})
        @host = host
        @options = options
      end

      private

      def connection
        @connection ||= set_connection
      end
      alias conn connection

      def set_connection
        Faraday.new(url: host, headers: default_headers)
          # conn.response :json, content_type: /\bjson$/
      end

      def default_headers
        { 'Accept' => 'application/json' }
      end
    end
  end
end
