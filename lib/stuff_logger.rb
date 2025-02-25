require 'logstuff'

module StuffLogger
  extend ActiveSupport::Concern

  included do
    def log_error(error, message)
      LogStuff.error(class: self.class.name,
                     action: caller_locations(1, 1)[0].label,
                     error_message: "#{error.class} - #{error.message}",
                     error_backtrace: error.backtrace.inspect) { message }
    end

    def log_info(message)
      LogStuff.info(class: self.class.name, action: caller_locations(1, 1)[0].label) { message }
    end
  end
end
