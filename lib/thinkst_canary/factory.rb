module ThinkstCanary
  class Factory
    include ThinkstCanary::APIQueryable

    attr_reader :factory_auth, :flock_id, :memo

    TOKEN_CLASS = {
      'doc-msword' => ThinkstCanary::Token::DocMsword,
      'pdf-acrobat-reader' => ThinkstCanary::Token::PdfAcrobatReader
    }.freeze

    def initialize(factory_auth:, flock_id: nil, memo: nil)
      @factory_auth = factory_auth
      @flock_id = flock_id
      @memo = memo
    end

    def create_token(**kwargs)
      klass(kwargs[:kind]).new(flock_id:, factory_auth:, **kwargs)
    end

    def delete
      query(:delete, '/api/v1/canarytoken/delete_factory', params: { factory_auth: })
    end

    def klass(kind)
      TOKEN_CLASS[kind] || ThinkstCanary::Token::NullToken
    end
  end
end
