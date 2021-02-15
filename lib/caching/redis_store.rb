require_relative 'abstract_store'

class Caching
  class RedisStore < AbstractStore
    def initialize
      self.store = Redis.current
    end

    def self.current
      self.instance ||= new
    end

    def get(key)
      store.get(key)
    end

    def set(key, value)
      store.set(key, value)
      value
    end
  end
end
