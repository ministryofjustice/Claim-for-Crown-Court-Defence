module SurveyMonkey
  class CollectorCollection
    def initialize
      @collectors = {}
    end

    def add(name, id:)
      @collectors[name] = Collector.new(name, id:)
    end

    def clear
      @collectors = {}
    end

    def [](name) = @collectors[name] || raise(UnregisteredCollector)
  end
end
