# Disable CSS3 and jQuery animations in test mode for speed, consistency and avoiding timing issues.
# see https://medium.com/doctolib/elements-in-motion-4d7c9f264b8
# Usage for Rails:
# in config/environments/test.rb
# config.middleware.use Rack::NoAnimations
#
require 'rack/injectable'
module Rack
  class NoAnimations
    include Injectable

    DISABLE_ANIMATIONS_HTML = <<~HTML.freeze
      <script type="text/javascript">
        if (typeof window.jQuery !== 'undefined') {
          window.jQuery(() => {
              window.jQuery.support.transition = false;
              if (typeof window.jQuery.fx !== 'undefined') {
                window.jQuery.fx.off = true;
              }
          });
        }
      </script>
      <style>
        * {
           -webkit-transition: .0s !important;
           transition: .0s !important;
           -webkit-transform: .0s !important;
           transform: .0s !important;
           -webkit-animation: .0s !important;
           animation: .0s !important;
        }
      </style>
    HTML

    private

    def fragment
      DISABLE_ANIMATIONS_HTML
    end
  end
end
