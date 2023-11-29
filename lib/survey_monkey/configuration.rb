module SurveyMonkey
  class Configuration
    attr_accessor :root_url, :bearer, :collector_id, :logger, :verbose_logging
    attr_reader :pages

    def initialize
      @pages = PageCollection.new
    end

    def connection
      @connection ||= Faraday.new(root_url) do |conn|
        conn.request :authorization, 'Bearer', bearer
        if logger && verbose_logging
          conn.response(:logger, logger, { headers: true, bodies: true }) do |log|
            log.filter(/(Authorization: )(.*)/, '\1[REMOVED]')
          end
        end
      end
    end

    def register_page(page, page_id, **)
      @pages.add(page, page_id, **)
    end
  end
end
