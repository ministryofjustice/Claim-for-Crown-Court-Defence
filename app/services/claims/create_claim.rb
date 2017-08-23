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
        MessageQueue::SendMessage.new(MessageQueue::Hashes.claim_created(claim.type, claim.uuid), Settings.aws.queue).send!
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
