module ThinkstCanary
  class FactoryGenerator
    include ThinkstCanary::ApiQueryable

    def create_factory(memo:, flock_id:)
      params = { memo: memo, flock_id: flock_id }
      factory_auth = query(:post, '/api/v1/canarytoken/create_factory', params: params)['factory_auth']
      ThinkstCanary::Factory.new(factory_auth: factory_auth, **params)
    end
  end
end
