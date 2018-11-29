# For debugging
module Debuggable
  extend ActiveSupport::Concern

  included do
    def debug(message, color = :yellow)
      contents = ['[DEBUG]', message].join(' ')
      contents = contents.send(color.to_sym) if color
      puts contents
    end
  end
end
