module ThinkstCanary
  class FactoryGenerator
    include ThinkstCanary::APIQueryable

    def create_factory(memo:, flock_id:)
      params = { memo:, flock_id: }
      factory_auth = query(:post, '/api/v1/canarytoken/create_factory', params:)['factory_auth']
      ThinkstCanary::Factory.new(factory_auth:, **params)
    end
  end
end
