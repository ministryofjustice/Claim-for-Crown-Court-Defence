class InjectionResponseService
  def initialize(json)
    @response = json.stringify_keys
    raise ParseError, 'Invalid JSON string' unless @response.keys.sort.eql?(%w[errors messages uuid])
    @claim = Claim::BaseClaim.find_by(uuid: @response['uuid'])
  end

  def run!
    slack = SlackNotifier.new
    slack.build_injection_payload(@response)
    if @claim.nil?
      LogStuff.send(:info, 'InjectionResponseService::NonExistentClaim',
                    action: 'run!',
                    uuid: @response['uuid']) { 'Failed to inject because no claim found' }
      slack.send_message!
      return false
    end
    ia = InjectionAttempt.create(claim: @claim, succeeded: ccr_injected?, error_message: error_message)
    slack.send_message!
    ia.save
  end

  private

  def ccr_injected?
    @response['errors'].empty? && @claim.present?
  end

  def error_message
    @response['errors'].join(' ')
  end
end
