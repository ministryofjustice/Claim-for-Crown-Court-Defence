class SlackNotifier
  class Formatter
    attr_reader :message_icon

    def initialize
      @colours = {
        pass: '#36a64f',
        fail: '#c41f1f'
      }
    end

    def attachment(*_args)
      {}
    end

    private

    def message_colour
      @colours[status]
    end
  end
end
