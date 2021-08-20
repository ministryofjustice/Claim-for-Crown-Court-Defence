class SlackNotifier
  def initialize(channel, formatter: nil)
    @formatter = formatter || Formatter.new
    @formatter.channel = channel
    @formatter.username = Settings.slack.bot_name
    @slack_url = Settings.slack.bot_url
  end

  def send_message!
    raise 'Unable to send without payload' unless @formatter.ready_to_send

    RestClient.post(@slack_url, @formatter.payload.to_json, content_type: :json)
  end

  def build_payload(*args)
    @formatter.build(*args)
  end
end
