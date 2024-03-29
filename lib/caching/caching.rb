class Caching
  class Caching
    cattr_accessor :backend

    class << self
      def method_missing(method, ...)
        if backend.current.respond_to?(method, false)
          backend.current.send(method, ...)
        else
          super
        end
      end

      def respond_to_missing?(method, include_private = false)
        backend.current.respond_to?(method, include_private) || super
      end
    end
  end
end
