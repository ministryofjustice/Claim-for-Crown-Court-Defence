require 'csv'

module Stats
  class FeeSchemeUsageGenerator
    def self.call(...)
      new(...).call
    end

    def initialize(**kwargs)
      @format = kwargs.fetch(:format, :csv)
    end

    def call

    end

  end
end
