class SlackNotifier
  def initialize
    @slack_url = Settings.slack.bot_url
    @ready_to_send = false
    @payload = {
      channel: Settings.slack.channel,
      username: Settings.slack.bot_name
    }
  end

  def send_message!
    raise 'Unable to send without payload' unless @ready_to_send

    RestClient.post(@slack_url, @payload.to_json, content_type: :json)
  end

  def build_injection_payload(response)
    @response = response.stringify_keys
    @claim = Claim::BaseClaim.find_by(uuid: @response['uuid'])
    @payload.merge(
      icon_emoji: ccr_injected? ? Settings.slack.success_icon : Settings.slack.fail_icon,
      attachments: [
        {
          'fallback': "#{generate_message} {#{@response['uuid']}}",
          'color': ccr_injected? ? '#36a64f' : '#c41f1f',
          'title': "Injection #{ccr_injected? ? 'succeeded' : 'failed'}",
          'text': @response['uuid'],
          'fields': fields
        }
      ]
    )
    @ready_to_send = true
  rescue StandardError
    @ready_to_send = false
  end

  private

  def ccr_injected?
    has_no_errors? && @claim.present?
  end

  def has_no_errors?
    @response['errors'].empty?
  end

  def error_message
    @response['errors'].join(' ')
  end

  def fields
    fields = [
      { 'title': 'Claim number', 'value': @claim&.case_number, 'short': true },
      { 'title': 'environment', 'value': ENV['ENV'], 'short': true }
    ]
    errors = has_no_errors? ? [] : error_fields
    fields + errors
  end

  def error_fields
    errors = @response['errors'].map { |x| x['error'] }.join('\n')
    [
      { 'title': 'Errors', 'value': errors }
    ]
  end

  def generate_message
    if @claim.nil?
      'Failed to inject because no claim found'
    elsif ccr_injected?
      "Claim #{@claim.case_number} successfully injected"
    else
      "Claim #{@claim.case_number} could not be injected"
    end
  end
end
