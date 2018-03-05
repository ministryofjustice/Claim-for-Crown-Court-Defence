class FeatureFlag
  class << self
    def active?(feature)
      enabled? && active_features.include?(feature.to_sym)
    end

    def enabled?
      Settings.feature_flags_enabled?
    end

    def active_features
      Settings.active_features || []
    end
  end
end
