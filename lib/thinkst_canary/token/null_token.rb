module ThinkstCanary
  module Token
    class NullToken < Base
      attr_reader :kind

      def initialize(**kwargs)
        @kind = kwargs[:kind]
        @canarytoken = "Unknown Canary kind '#{kwargs[:kind]}'"

        super(**kwargs)
      end
    end
  end
end
