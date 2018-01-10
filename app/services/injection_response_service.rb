class InjectionResponseService
  def initialize(json)
    @response = json.stringify_keys
    raise ParseError, 'Invalid JSON string' unless @response.keys.sort.eql?(%w[errors messages uuid])
    @claim = Claim::BaseClaim.find_by(uuid: @response['uuid'])
  end

  def run!
    slack.build_injection_payload(@response)
    if @claim.nil?
      LogStuff.send(:info, 'InjectionResponseService::NonExistentClaim',
                    action: 'run!',
                    uuid: @response['uuid']) { 'Failed to inject because no claim found' }
      slack.send_message!
      return false
    end
    # FIXME: simplify - does the slack message need to be sent after, before or during injection attempt record creation
    ia = create_injection_attempt
    slack.send_message!
    ia.persisted?
  end

  private

  def slack
    @slack ||= SlackNotifier.new
  end

  def injected?
    @response['errors'].empty? && @claim.present?
  end

  def error_message
    @response['errors'].join(' ')
  end

  def error_messages
    @response.slice('errors')
  end

  def create_injection_attempt
    InjectionAttempt.create(claim: @claim,
                            succeeded: injected?,
                            error_message: error_message,
                            error_messages: error_messages)
  end
end
