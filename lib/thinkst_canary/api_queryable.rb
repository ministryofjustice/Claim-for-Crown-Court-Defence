require 'forwardable'

module ThinkstCanary
  module ApiQueryable
    extend Forwardable

    def_delegator :configuration, :query

    private

    def configuration
      ThinkstCanary.configuration
    end
  end
end
