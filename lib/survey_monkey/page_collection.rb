module SurveyMonkey
  class PageCollection
    def initialize
      @pages = {}
    end

    def add(name, id:, collector:, questions: {})
      @pages[name] = Page.new(name, id:, collector:, questions:)
    end

    def clear
      @pages = {}
    end

    def [](name) = @pages[name] || raise(UnregisteredPage)
  end
end
