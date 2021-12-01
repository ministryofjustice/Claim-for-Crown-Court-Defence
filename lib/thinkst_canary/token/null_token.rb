module ThinkstCanary
  module Token
    class NullToken < Base
      def initialize(**options)
        @canary_token = "Unknown Canary kind '#{options[:kind]}'"

        super
      end
    end
  end
end
