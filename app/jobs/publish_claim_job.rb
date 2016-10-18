class PublishClaimJob < ActiveJob::Base
  queue_as :claims

  def perform(claim)
    Messaging::ClaimMessage.new(claim).publish
  end
end
