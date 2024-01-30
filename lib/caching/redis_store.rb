require_relative 'abstract_store'

class Caching
  class RedisStore < AbstractStore
    delegate :get, to: :store

    def initialize
      self.store = Redis.new(url: ENV.fetch('REDIS_URL'))
    end

    def self.current
      self.instance ||= new
    end

    def set(key, value)
      store.set(key, value)
      value
    end
  end
end
