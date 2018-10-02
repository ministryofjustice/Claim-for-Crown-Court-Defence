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

    create_injection_attempt
    slack.send_message!
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
end
