module SurveyMonkey
  class PageCollection
    def initialize
      @pages = []
    end

    def add(page, id:, collector:, questions: {})
      @pages.reject! { |p| p.name == page }
      @pages << Page.new(page, id:, collector:, questions:)
    end

    def clear
      @pages = []
    end

    def page_by_name(name)
      @pages.find { |page| page.name == name } || raise(UnregisteredPage)
    end
  end
end
