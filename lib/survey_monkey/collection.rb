module SurveyMonkey
  class Collection
    def initialize(collectable)
      @items = {}
      @collectable = collectable
    end

    def add(name, **)
      @items[name] = @collectable.new(name, **)
    end

    def clear
      @items = {}
    end

    def [](name) = @items[name] || raise(@collectable.unregistered_exception)
  end
end
