# NOTE: credit to https://metaskills.net/2013/12/15/instrumenting-your-code-with-activesupport-notifications/

module Subscribers
  class Base
    attr_reader :event

    def initialize(*args)
      @event = ActiveSupport::Notifications::Event.new(*args)
      process
    end

    def process
      raise NotImplementedError
    end
  end
end
