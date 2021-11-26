module ThinkstCanary
  module Token
    class NullToken < Base
      def initialize(**kwargs)
        @canarytoken = "Unknown Canary kind '#{kwargs[:kind]}'"

        super
      end
    end
  end
end
