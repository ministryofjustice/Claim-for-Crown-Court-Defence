module Providers
  class RegenerateApiKey
    def self.call(provider)
      provider.update_column(:api_key, SecureRandom.uuid)
    end
  end
end
