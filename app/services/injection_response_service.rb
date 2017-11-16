class InjectionResponseService
  def initialize(json)
    @response = json.stringify_keys
    raise ParseError, 'Invalid JSON string' unless @response.keys.sort.eql?(%w[errors messages uuid])
  end

  def run!
    claim = Claim::BaseClaim.find_by(uuid: @response['uuid'])
    if claim.nil?
      failure_message = 'Failed to inject because no claim found'
      LogStuff.send(:info, 'InjectionResponseService::NonExistentClaim',
                    action: 'run!',
                    uuid: @response['uuid']) { failure_message }
      update_slack(failure_message)
      return false
    end
    ia = InjectionAttempt.create(claim: claim, succeeded: ccr_injected?, error_message: error_message)
    update_slack(generate_message(ccr_injected?, claim))
    ia.save
  end

  private

  def generate_message(success, claim)
    if success
      "Claim #{claim.case_number} successfully injected"
    else
      "Claim #{claim.case_number} could not be injected because #{error_message}"
    end
  end

  def update_slack(message)
    payload = {
      channel: Settings.slack.channel,
      username: Settings.slack.bot_name,
      text: "#{message} {#{@response['uuid']}}",
      icon_emoji: Settings.slack.icon
    }.to_json
    RestClient.post(Settings.slack.bot_url, payload, content_type: :json)
  end

  def ccr_injected?
    @response['errors'].empty?
  end

  def error_message
    @response['errors'].join(' ')
  end
end
