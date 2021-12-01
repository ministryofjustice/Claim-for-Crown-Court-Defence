module ThinkstCanary
  class Token
    attr_reader :memo, :kind, :canary_token

    def initialize(memo:, kind:, canary_token:)
      @memo = memo
      @kind = kind
      @canary_token = canary_token
    end
  end
end
