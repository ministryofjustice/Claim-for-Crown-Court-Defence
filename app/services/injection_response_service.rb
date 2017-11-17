class InjectionResponseService
  def initialize(json)
    @response = json.stringify_keys
    raise ParseError, 'Invalid JSON string' unless @response.keys.sort.eql?(%w[errors messages uuid])
  end

  def run!
    @claim = Claim::BaseClaim.find_by(uuid: @response['uuid'])
    if @claim.nil?
      failure_message = 'Failed to inject because no claim found'
      LogStuff.send(:info, 'InjectionResponseService::NonExistentClaim',
                    action: 'run!',
                    uuid: @response['uuid']) { failure_message }
      update_slack(failure_message)
      return false
    end
    ia = InjectionAttempt.create(claim: @claim, succeeded: ccr_injected?, error_message: error_message)
    update_slack(generate_message)
    ia.save
  end

  private

  def generate_message
    if ccr_injected?
      "Claim #{@claim.case_number} successfully injected"
    else
      "Claim #{@claim.case_number} could not be injected"
    end
  end

  def update_slack(message)
    payload = {
      channel: Settings.slack.channel,
      username: Settings.slack.bot_name,
      icon_emoji: Settings.slack.icon,
      attachments: [
        {
          'fallback': "#{message} {#{@response['uuid']}}",
          'color': ccr_injected? ? '#36a64f' : '#c41f1f',
          'title': 'UUID',
          'text': @response['uuid'],
          'fields': fields(message)
        }
      ]
    }.to_json
    RestClient.post(Settings.slack.bot_url, payload, content_type: :json)
  end

  def fields(message)
    fields = [
      { 'title': "Injection #{ccr_injected? ? 'succeeded' : 'failed'}", 'value': message, 'short': true },
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

  def has_no_errors?
    @response['errors'].empty?
  end

  def ccr_injected?
    has_no_errors? && @claim.present?
  end

  def error_message
    @response['errors'].join(' ')
  end
end
