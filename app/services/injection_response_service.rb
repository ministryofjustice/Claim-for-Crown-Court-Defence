class InjectionResponseService
  def initialize(json)
    @response = json.stringify_keys
    raise ParseError, 'Invalid JSON string' unless @response.keys.sort.eql?(%w[errors from messages uuid])
    @claim = Claim::BaseClaim.find_by(uuid: @response['uuid'])
    @channel = Claims::InjectionChannel.for(@claim)
  end

  def run!
    slack.build_injection_payload(@response)
    return failure(action: 'run!', uuid: @response['uuid']) unless @claim

    injection_attempt
    # TEMP: always send slack message for live-1 SQS response queue
    if Settings.aws&.response_queue&.match?('laa-get-paid')
      slack.send_message!
    else
      slack.send_message! unless injection_attempt.notification_can_be_skipped?
    end
    true
  end

  private

  def slack
    @slack ||= SlackNotifier.new(@channel)
  end

  def failure(options = {})
    LogStuff.info('InjectionResponseService::NonExistentClaim', options) { 'Failed to inject because no claim found' }
    slack.send_message!
    false
  end

  def injected?
    @response['errors'].empty? && @claim.present?
  end

  def error_messages
    @response.slice('errors')
  end

  def create_injection_attempt
    InjectionAttempt.create(claim: @claim,
                            succeeded: injected?,
                            error_messages: error_messages)
  end

  def injection_attempt
    @injection_attempt ||= create_injection_attempt
  end
end
