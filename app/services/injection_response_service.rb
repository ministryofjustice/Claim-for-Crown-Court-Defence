class InjectionResponseService
  def initialize(json)
    @response = json.symbolize_keys
    raise ParseError, 'Invalid JSON string' unless @response.keys.sort.eql?(%i[errors from messages uuid])
    @claim = Claim::BaseClaim.find_by(uuid: @response[:uuid])
    @channel = Claims::InjectionChannel.for(@claim)
  end

  def run!
    slack_notifier.build_payload(**@response)
    return failure(action: 'run!', uuid: @response[:uuid]) unless @claim

    injection_attempt
    slack_notifier.send_message unless injection_attempt.notification_can_be_skipped?
    true
  end

  private

  def slack_notifier
    @slack_notifier ||= SlackNotifier.new(@channel, formatter: SlackNotifier::Formatter::Injection.new)
  end

  # rubocop:disable Naming/PredicateMethod
  def failure(options = {})
    LogStuff.info('InjectionResponseService::NonExistentClaim', **options) { 'Failed to inject because no claim found' }
    slack_notifier.send_message
    false
  end
  # rubocop:enable Naming/PredicateMethod

  def injected?
    @response[:errors].empty? && @claim.present?
  end

  def error_messages
    @response.slice(:errors)
  end

  def create_injection_attempt
    InjectionAttempt.create(claim: @claim,
                            succeeded: injected?,
                            error_messages:)
  end

  def injection_attempt
    @injection_attempt ||= create_injection_attempt
  end
end
