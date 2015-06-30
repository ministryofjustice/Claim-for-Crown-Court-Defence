# == Schema Information
#
# Table name: case_worker_claims
#
#  id             :integer          not null, primary key
#  case_worker_id :integer
#  claim_id       :integer
#  created_at     :datetime
#  updated_at     :datetime
#

class CaseWorkerClaim < ActiveRecord::Base
  belongs_to :case_worker
  belongs_to :claim

  after_create :generate_message_statuses
  after_create :set_claim_allocated!

  private

  def generate_message_statuses
    messages = claim.messages
    user = case_worker.user
    messages.each do |message|
      UserMessageStatus.create!(user_id: user.id, message_id: message.id)
    end
  end

  def set_claim_allocated!
    claim.allocate! if claim.submitted?
  end
end
