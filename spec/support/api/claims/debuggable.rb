# For debugging
module Debuggable
  extend ActiveSupport::Concern

  included do
    attr_writer :debug

    def debug(message, color = :yellow)
      return unless @debug

      contents = ['[DEBUG]', message].join(' ')
      contents = contents.send(color.to_sym) if color
      puts contents
    end
  end
end
