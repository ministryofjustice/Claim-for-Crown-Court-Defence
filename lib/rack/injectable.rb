module Rack
  module Injectable
    def initialize(app)
      @app = app
    end

    def call(env)
      status, headers, body = @app.call(env)
      return status, headers, body unless html?(headers)
      response = Rack::Response.new([], status, headers)

      body.each { |chunk| response.write inject(chunk) }
      body.close if body.respond_to?(:close)
      response.finish
    end

    private

    def html?(headers)
      headers['Media-Type'] =~ /html/
    end

    # implement in class into which it is included
    def fragment
      <<~HTML
        my html here
      HTML
    end

    def inject(body_chunk)
      body_chunk.gsub('</body>', fragment + '</body>')
    end
  end
end
