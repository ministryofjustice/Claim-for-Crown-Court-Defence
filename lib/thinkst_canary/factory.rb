module ThinkstCanary
  class Factory
    include ThinkstCanary::ApiQueryable

    attr_reader :factory_auth, :flock_id, :memo

    TOKEN_CLASS = {
      'doc-msword' => ThinkstCanary::Token::DocMsword
    }.freeze

    def initialize(factory_auth:, flock_id: nil, memo: nil)
      @factory_auth = factory_auth
      @flock_id = flock_id
      @memo = memo
    end

    def create_token(memo:, kind:, **options)
      return ThinkstCanary::Token::NullToken.new(memo: memo, kind: kind) unless TOKEN_CLASS.key?(kind)

      TOKEN_CLASS[kind].new(memo: memo, flock_id: flock_id, factory_auth: factory_auth, **options)
    end

    def delete
      query(:delete, '/api/v1/canarytoken/delete_factory', params: { factory_auth: factory_auth })
    end
  end
end
