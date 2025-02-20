# frozen_string_literal: true

module Rule
  class Set
    include Enumerable

    attr_reader :object

    delegate :<<, to: :@rules

    def initialize(object)
      @object = object
      @rules = []
    end

    def each(&)
      @rules.each(&)
    end
  end
end
