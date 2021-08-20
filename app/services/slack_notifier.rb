class SlackNotifier
  def initialize(channel, formatter: nil)
    @formatter = formatter || Formatter.new
    @formatter.channel = channel
    @formatter.username = Settings.slack.bot_name
    @slack_url = Settings.slack.bot_url
    @ready_to_send = false
  end

  def send_message!
    raise 'Unable to send without payload' unless @formatter.ready_to_send

    RestClient.post(@slack_url, @formatter.payload.to_json, content_type: :json)
  end

  def build_generic_payload(message_icon, title, message, pass_fail)
    @formatter.build(icon: message_icon, title: title, message: message, status: (pass_fail ? :pass : :fail))
  end

  def build_injection_payload(response)
    @formatter.build(**response)
  end
end
