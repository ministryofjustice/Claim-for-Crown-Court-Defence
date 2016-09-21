module Caching
  class << self
    cattr_accessor :backend

    def method_missing(method, *args, &block)
      backend.current.send(method, *args, &block)
    end
  end
end
