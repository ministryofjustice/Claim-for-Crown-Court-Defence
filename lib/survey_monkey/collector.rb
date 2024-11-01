module SurveyMonkey
  class Collector
    attr_reader :id, :name

    def initialize(name, id:)
      @id = id
      @name = name
    end
  end
end
