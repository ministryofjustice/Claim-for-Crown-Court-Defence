module ThinkstCanary
  module Token
    class Base
      extend Forwardable

      attr_reader :memo

      def_delegator :configuration, :post_query

      def initialize(**options)
        @options = options
        @memo = options[:memo]

        canary_token
      end

      def canary_token
        @canary_token ||= @options[:canary_token] || fetch_token
      end

      private

      def configuration
        ThinkstCanary.configuration
      end

      def fetch_token
        params = { type: @type, **@options }
        response = post_query('/api/v1/canarytoken/factory/create', auth: false, params: params)
        @canary_token = response['canarytoken']['canarytoken']
      end
    end
  end
end
