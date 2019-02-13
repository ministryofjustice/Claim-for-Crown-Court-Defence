# Disable alerts during headless chrome run
#
class Rack::NoPopups
  DISABLE_POPUPS_HTML = <<~HTML.freeze
    <script type="text/javascript">
      window.alert = function() { };
      window.confirm = function() { return true; };
    </script>
  HTML

  def initialize(app)
    @app = app
  end

  def call(env)
    status, headers, body = @app.call(env)
    return status, headers, body unless html?(headers)
    response = Rack::Response.new([], status, headers)

    body.each { |fragment| response.write inject(fragment) }
    body.close if body.respond_to?(:close)
    response.finish
  end

  private

  def html?(headers)
    headers['Content-Type'] =~ /html/
  end

  def inject(fragment)
    fragment.gsub('</body>', DISABLE_POPUPS_HTML + '</body>')
  end
end
