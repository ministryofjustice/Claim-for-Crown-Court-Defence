# frozen_string_literal: true

module Rule
  class Set
    include Enumerable

    attr_reader :object

    def initialize(object)
      @object = object
      @rules = []
    end

    def <<(rule)
      @rules << rule
    end

    def each(&block)
      @rules.each(&block)
    end
  end
end
