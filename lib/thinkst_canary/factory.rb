require 'forwardable'

module ThinkstCanary
  class Factory
    extend Forwardable

    attr_reader :factory_auth, :flock_id, :memo

    def_delegator :configuration, :post_query

    def initialize(factory_auth:, flock_id:, memo:)
      @factory_auth = factory_auth
      @flock_id = flock_id
      @memo = memo
    end

    def create_token(memo:, kind:)
      params = { memo: memo, kind: kind, flock_id: @flock_id, factory_auth: @factory_auth }
      response = post_query('/api/v1/canarytoken/factory/create', auth: false, params: params)
      canary_token = response['canarytoken']['canarytoken']

      ThinkstCanary::Token.new(memo: memo, kind: kind, canary_token: canary_token)
    end

    private

    def configuration
      ThinkstCanary.configuration
    end
  end
end
