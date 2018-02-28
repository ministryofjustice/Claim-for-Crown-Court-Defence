class FeatureFlag
  class << self
    def active?(feature)
      enabled? && list.include?(feature.to_sym)
    end

    def enabled?
      ENV['FEATURE_FLAGS_ENABLED'].to_s.casecmp('true').zero?
    end

    def config
      @config ||= OpenStruct.new
    end

    def configure(&_block)
      config.tap { yield(config) }
    end

    def list
      config.features || []
    end
  end
end
