class RailsHost
  VALID_ENVS = %w[dev demo staging api-sandbox gamma].freeze

  def self.env
    ENV['ENV']
  end

  def self.method_missing(method)
    env_name = method.to_s.tr('_', '-').sub(/\?$/, '')
    if VALID_ENVS.include?(env_name)
      env == env_name
    else
      super
    end
  end

  def self.respond_to_missing?(method, include_private = false)
    env_name = method.to_s.tr('_', '-').sub(/\?$/, '')
    VALID_ENVS.include?(env_name) || super
  end
end
