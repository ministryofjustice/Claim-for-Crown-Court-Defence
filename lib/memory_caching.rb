class MemoryCaching
  cattr_accessor :instance, :store

  def initialize
    self.store = Hash.new
  end
  private_class_method :new

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
