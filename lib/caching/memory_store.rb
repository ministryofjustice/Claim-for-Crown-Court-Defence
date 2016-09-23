require_relative 'abstract_store'

module Caching
  class MemoryStore < AbstractStore
    def initialize
      self.store = Hash.new
    end

    def self.current
      self.instance ||= new
    end

    def get(key)
      self.store[key]
    end

    def set(key, value)
      self.store[key] = value
    end

    def clear
      self.store.clear
    end
  end
end
