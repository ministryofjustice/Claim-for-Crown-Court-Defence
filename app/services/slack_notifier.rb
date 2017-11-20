class SlackNotifier
  def initialize
    @slack_url = Settings.slack.bot_url
    @ready_to_send = false
  end

  def send_message!
    raise 'Unable to send without payload' unless @ready_to_send

    RestClient.post(@slack_url, {})
  end

  def build_injection
    # {
    #   channel: Settings.slack.channel,
    #   username: Settings.slack.bot_name,
    #   icon_emoji: ccr_injected? ? Settings.slack.success_icon : Settings.slack.fail_icon,
    #   attachments: [
    #     {
    #       'fallback': "#{generate_message} {#{@response['uuid']}}",
    #       'color': ccr_injected? ? '#36a64f' : '#c41f1f',
    #       'title': "Injection #{ccr_injected? ? 'succeeded' : 'failed'}",
    #       'text': @response['uuid'],
    #       'fields': fields
    #     }
    #   ]
    # }.to_json
    @ready_to_send = true
  end
end
