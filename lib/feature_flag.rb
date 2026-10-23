class FeatureFlag
  class << self
    def active?(feature)
      enabled? && active_features.include?(feature.to_sym)
    end

    def enabled?
      Settings.feature_flags_enabled?
    end

    def active_features
      features = Array(Settings.active_features).map(&:to_sym)
      features |= [:dual_login] if Settings.dual_login_enabled?
      features
    end
  end
end
