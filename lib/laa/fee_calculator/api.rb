module LAA
  module FeeCalculator
    class API
      include Singleton
      extend Forwardable

      class << self
        attr_accessor :configuration
        alias config configuration

        def configuration
          @configuration ||= Configuration.new
        end

        def configure
          yield(configuration)
          configuration
        end
      end

      def_delegators :client, :get, :post, :put, :patch, :delete

      def initialize
        @client = Client.new(config.host)
      end

      def configuration
        self.class.configuration
      end
      alias config configuration

      private

      attr_reader :client
    end
  end
end
