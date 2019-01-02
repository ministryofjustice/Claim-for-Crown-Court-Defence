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
      required_keys_as_hash.values
    end

    def required_keys_as_hash
      required_keys.to_h
    end

    def required_keys
      @values.except(:count)
    end
  end
end
