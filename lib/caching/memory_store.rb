require_relative 'abstract_store'

class Caching
  class MemoryStore < AbstractStore
    delegate :clear, to: :store

    def initialize
      self.store = {}
    end

    def self.current
      self.instance ||= new
    end

    def get(key)
      store[key]
    end

    def set(key, value)
      store[key] = value
    end
  end
end
