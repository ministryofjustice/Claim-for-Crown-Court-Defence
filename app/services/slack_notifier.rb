class SlackNotifier
  def initialize(channel, formatter: nil)
    @formatter = formatter
    @slack_url = Settings.slack.bot_url
    @ready_to_send = false
    @payload = {
      channel: channel,
      username: Settings.slack.bot_name
    }
  end

  def send_message!
    raise 'Unable to send without payload' unless @ready_to_send

    RestClient.post(@slack_url, @payload.to_json, content_type: :json)
  end

  def build_generic_payload(message_icon, title, message, pass_fail)
    @formatter = Formatter::Generic.new
    build_payload(icon: message_icon, title: title, message: message, pass_fail: pass_fail)
  end

  def build_injection_payload(response)
    @formatter = Formatter::Injection.new
    build_payload(**response.symbolize_keys)
  end

  def build_payload(*args)
    @payload[:attachments] = [@formatter.build(*args)]
    @payload[:icon_emoji] = @formatter.message_icon
    @ready_to_send = true
  rescue StandardError
    @ready_to_send = false
  end
end
