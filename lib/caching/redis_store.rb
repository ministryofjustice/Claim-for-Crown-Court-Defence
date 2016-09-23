require_relative 'abstract_store'

module Caching
  class RedisStore < AbstractStore
    def initialize
      self.store = Redis.current
    end

    def self.current
      self.instance ||= new
    end

    def get(key)
      self.store.get(key)
    end

    def set(key, value)
      self.store.set(key, value)
      value
    end
  end
end
