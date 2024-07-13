require 'forwardable'

module CourtDataAdaptor
  class OauthAdapter
    class Response < SimpleDelegator
      extend Forwardable

      def_delegator :response, :env
      def_delegator :self, :parsed, :body
    end
  end
end
