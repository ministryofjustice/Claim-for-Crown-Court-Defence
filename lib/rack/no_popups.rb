# Disable alerts during headless chrome run
#
require 'rack/injectable'
module Rack
  class NoPopups
    include Injectable

    ENABLED = true

    DISABLE_POPUPS_HTML = <<~HTML.freeze
      <script type="text/javascript">
        window.alert = function() { };
        window.confirm = function() { return true; };
      </script>
    HTML

    private

    def enabled?
      ENABLED
    end

    def fragment
      enabled? ? DISABLE_POPUPS_HTML : ''
    end
  end
end
