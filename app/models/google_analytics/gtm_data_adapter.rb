module GoogleAnalytics
  class GTMDataAdapter < DataAdapter
    def templates
      {
        virtual_page: { event: 'VirtualPageview', virtualPageURL: '%{url}', virtualPageTitle: '%{title}' }
      }.freeze
    end

    def to_s
      "dataLayer.push(#{template_data.to_json});"
    end
  end
end
