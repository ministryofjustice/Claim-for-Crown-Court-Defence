class SlackNotifier
  class Formatter
    attr_reader :payload, :ready_to_send
    attr_writer :channel, :username

    def initialize
      @payload = {}
      @ready_to_send = false
    end

    def build(message_icon, title, message, pass_fail)
      @payload = {
        channel: @channel,
        username: @username,
        icon_emoji: message_icon,
        attachments: [
          {
            fallback: message,
            color: pass_fail_colour(pass_fail),
            title: title,
            text: message
          }
        ]  
      }
      @ready_to_send = true
    rescue StandardError
      @ready_to_send = false
    end  

    private

    def pass_fail_colour(boolean)
      boolean ? '#36a64f' : '#c41f1f'
    end
  end
end