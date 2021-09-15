module SurveyMonkey
  class Configuration
    attr_accessor :root_url, :bearer, :collector_id
    attr_reader :pages

    def initialize
      @pages = PageCollection.new
    end

    def connection
      @connection ||= Faraday.new(root_url) do |conn|
        conn.authorization :Bearer, bearer
      end
    end

    def register_page(page, page_id, **questions)
      @pages.add(page, page_id, **questions)
    end
  end
end
