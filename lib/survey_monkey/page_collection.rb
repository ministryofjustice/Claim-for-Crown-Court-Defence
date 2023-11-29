module SurveyMonkey
  class PageCollection
    def initialize
      @pages = []
    end

    def add(page, page_id, **)
      @pages.reject! { |p| p.name == page }
      @pages << Page.new(page, page_id, **)
    end

    def page_by_name(name)
      @pages.find { |page| page.name == name } || raise(UnregisteredPage)
    end
  end
end
