class SlackNotifier
  def initialize(channel)
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
    @payload[:icon_emoji] = message_icon
    @payload[:attachments] = [
      {
        'fallback': message,
        'color': pass_fail_colour(pass_fail),
        'title': title,
        'text': message
      }
    ]
    @ready_to_send = true
  rescue StandardError
    @ready_to_send = false
  end

  def build_injection_payload(response)
    @response = response.stringify_keys
    @claim = Claim::BaseClaim.find_by(uuid: @response['uuid'])
    @payload[:icon_emoji] = message_icon
    @payload[:attachments] = [
      {
        'fallback': injection_fallback,
        'color': message_colour,
        'title': injection_title,
        'text': @response['uuid'],
        'fields': fields
      }
    ]
    @ready_to_send = true
  rescue StandardError
    @ready_to_send = false
  end

  private

  def injected?
    has_no_errors? && @claim.present?
  end

  def injection_fallback
    "#{generate_message} {#{@response['uuid']}}"
  end

  def injection_title
    "Injection into #{app_name} #{injected? ? 'succeeded' : 'failed'}"
  end

  def app_name
    @response['from'] || 'indeterminable system'
  end

  def has_no_errors?
    @response['errors'].empty?
  end

  def error_message
    @response['errors'].join(' ')
  end

  def pass_fail_colour(boolean)
    boolean ? '#36a64f' : '#c41f1f'
  end

  def message_colour
    pass_fail_colour(injected?)
  end

  def message_icon
    injected? ? Settings.slack.success_icon : Settings.slack.fail_icon
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
    elsif injected?
      "Claim #{@claim.case_number} successfully injected"
    else
      "Claim #{@claim.case_number} could not be injected"
    end
  end
end
