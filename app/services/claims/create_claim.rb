module Claims
  class CreateClaim < ClaimActionsService
    def initialize(claim)
      self.claim = claim
      self.validate = true
    end

    def call
      if already_submitted?
        set_error_code(:already_submitted)
        return result
      end

      save_claim!(validate?)

      begin
        MessageQueue::AwsClient.new(MessageQueue::MessageTemplate.claim_created(claim.type, claim.uuid), Settings.aws.queue).send_message!
      rescue => err
        Rails.logger.warn "Error: '#{err.message}' while sending message about claim##{claim.id}(#{claim.uuid})"
      end

      result
    end

    def action
      :new
    end
  end
end
