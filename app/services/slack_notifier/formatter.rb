class SlackNotifier
  class Formatter
    def initialize
      @colours = {
        pass: '#36a64f',
        fail: '#c41f1f'
      }
    end

    private

    def message_colour
      @colours[status]
    end
  end
end
