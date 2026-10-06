class SlackNotifier
  WEBHOOK_SETTINGS_BY_CHANNEL = {
    'laa-cccd-alerts' => :laa_cccd_alerts_webhook,
    'cccd_development' => :cccd_development_webhook,
    'cccd_ccr_injection' => :cccd_ccr_injection_webhook,
    'cccd_cclf_injection' => :cccd_cclf_injection_webhook
  }.freeze
  private_constant :WEBHOOK_SETTINGS_BY_CHANNEL

  def initialize(channel, formatter:)
    @formatter = formatter
    webhook_setting = WEBHOOK_SETTINGS_BY_CHANNEL.fetch(channel) do
      raise ArgumentError, "No Slack webhook configured for channel: #{channel}"
    end
    @slack_url = Settings.slack.public_send(webhook_setting)
    @ready_to_send = false
    @payload = {}
  end

  def send_message
    raise 'Unable to send without payload' unless @ready_to_send

    Faraday.post(@slack_url, @payload.to_json, { 'Content-Type': 'application/json' })
  end

  def build_payload(**)
    @payload[:attachments] = [@formatter.attachment(**)]
    @ready_to_send = true
  rescue StandardError
    @ready_to_send = false
  end
end
