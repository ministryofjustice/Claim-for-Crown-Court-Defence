class InjectionResponseService
  def initialize(json)
    @response = json.symbolize_keys
    raise ParseError, 'Invalid JSON string' unless @response.keys.sort.eql?(%i[errors from messages uuid])
    @claim = Claim::BaseClaim.find_by(uuid: @response[:uuid])
    @channel = Claims::InjectionChannel.for(@claim)
  end

  def run!
    slack.build_payload(**@response)
    return failure(action: 'run!', uuid: @response[:uuid]) unless @claim

    injection_attempt
    slack.send_message unless injection_attempt.notification_can_be_skipped?
    true
  end

  private

  def slack
    @slack ||= SlackNotifier.new(@channel, formatter: SlackNotifier::Formatter::Injection.new)
  end

  def failure(options = {})
    LogStuff.info('InjectionResponseService::NonExistentClaim', options) { 'Failed to inject because no claim found' }
    slack.send_message
    false
  end

  def injected?
    @response[:errors].empty? && @claim.present?
  end

  def error_messages
    @response.slice(:errors)
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
