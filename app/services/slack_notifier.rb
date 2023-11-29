class SlackNotifier
  def initialize(channel, formatter:, slack_bot_name: Settings.slack.bot_name)
    @formatter = formatter
    @slack_url = Settings.slack.bot_url
    @ready_to_send = false
    @payload = {
      channel:,
      username: slack_bot_name
    }
  end

  def send_message
    raise 'Unable to send without payload' unless @ready_to_send

    RestClient.post(@slack_url, @payload.to_json, content_type: :json)
  end

  def build_payload(**)
    @payload[:attachments] = [@formatter.attachment(**)]
    @payload[:icon_emoji] = @formatter.message_icon
    @ready_to_send = true
  rescue StandardError
    @ready_to_send = false
  end
end
