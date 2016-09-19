module Caching
  class << self
    def backend=(backend)
      @backend = backend
    end

    def backend
      @backend
    end

    def method_missing(method, *args, &block)
      backend.send(method, *args, &block)
    end
  end
end
