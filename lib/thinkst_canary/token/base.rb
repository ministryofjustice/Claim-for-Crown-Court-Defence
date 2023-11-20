module ThinkstCanary
  module Token
    class Base
      include ThinkstCanary::APIQueryable

      attr_reader :memo, :canarytoken

      def initialize(**kwargs)
        @kind = kwargs[:kind]
        @memo = kwargs[:memo]
        @flock_id = kwargs[:flock_id]
        @factory_auth = kwargs[:factory_auth]

        @canarytoken ||= kwargs[:canarytoken] || fetch_token
      end

      def download
        params = { factory_auth: @factory_auth, canarytoken: }
        query(:get, '/api/v1/canarytoken/factory/download', auth: false, json: false, params:)
      end

      private

      def fetch_token
        response = query(:post, '/api/v1/canarytoken/factory/create', auth: false, params: create_options)
        @canarytoken = response['canarytoken']['canarytoken']
      end

      def create_options
        { kind: @kind, memo: @memo, flock_id: @flock_id, factory_auth: @factory_auth }
      end
    end
  end
end
