module GoogleAnalytics
  class GADataAdapter < DataAdapter

    def templates
      {
        virtual_page: {hitType: 'pageview', page: '%{url}', title: '%{title}'}
      }.freeze
    end

    def to_s
      "ga('send', #{template_data.to_json});"
    end

  end
end
