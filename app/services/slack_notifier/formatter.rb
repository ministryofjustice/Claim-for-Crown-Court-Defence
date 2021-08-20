class SlackNotifier
  class Formatter
    attr_reader :payload, :ready_to_send
    attr_writer :channel, :username

    def initialize
      @payload = {}
      @ready_to_send = false
      @colours = {
        pass: '#36a64f',
        fail: '#c41f1f'
      }
    end

    def build(**data)
      prebuild(**data)

      @payload = {
        channel: @channel,
        username: @username,
        icon_emoji: message_icon,
        attachments: [attachment]
      }
      @ready_to_send = true
    rescue StandardError
      @ready_to_send = false
    end

    private

    def prebuild(**data)
      @data = data
    end

    def attachment
      {
        fallback: message_fallback,
        color: message_colour,
        title: message_title,
        text: message_text
      }
    end

    def message_icon
      @data[:icon]
    end

    def message_fallback
      @data[:message]
    end

    def message_colour
      @colours[status]
    end

    def status
      @data[:status]
    end

    def message_title
      @data[:title]
    end

    def message_text
      @data[:message]
    end

    def pass_fail_colour(boolean)
      boolean ? '#36a64f' : '#c41f1f'
    end
  end
end
