module PerformancePlatform
  class DataSet
    def initialize(opts = {})
      @values = opts
    end

    def payload
      hash = { _id: build_id }
      hash.merge(@values)
    end

    private

    attr_accessor :values

    def build_id
      Base64.strict_encode64(required_values.join('.'))
    end

    def required_values
      required_keys.values
    end

    def required_keys
      default_keys = %i[_timestamp service period]
      default_keys << :channel if @values.key?(:channel)
      @values.reject { |key| !default_keys.include?(key.to_sym) }
    end
  end
end
