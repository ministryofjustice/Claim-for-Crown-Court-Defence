class Caching
  class AbstractStore
    cattr_accessor :instance, :store
    private_class_method :new

    def self.current
      raise 'not implemented'
    end

    def get(_key)
      raise 'not implemented'
    end

    def set(_key, _value)
      raise 'not implemented'
    end

    def clear
      raise 'not implemented'
    end
  end
end
