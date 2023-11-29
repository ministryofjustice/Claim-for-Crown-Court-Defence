# NOTE: credit to https://metaskills.net/2013/12/15/instrumenting-your-code-with-activesupport-notifications/

module Subscribers
  class Base
    attr_reader :event

    def initialize(*)
      @event = ActiveSupport::Notifications::Event.new(*)
      process
    end

    def process
      raise NotImplementedError
    end
  end
end
