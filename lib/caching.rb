module Caching
  class << self
    def backend=(backend)
      @backend = backend
    end

    def backend
      @backend
    end

    def get(key)
      backend.get(key)
    end

    def set(key, value)
      backend.set(key, value)
      value
    end

    def method_missing(method, *args, &block)
      backend.send(method, *args, &block)
    end
  end
end
