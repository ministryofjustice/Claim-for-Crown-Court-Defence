# == Schema Information
#
# Table name: claim_state_transitions
#
#  id          :integer          not null, primary key
#  claim_id    :integer
#  namespace   :string
#  event       :string
#  from        :string
#  to          :string
#  created_at  :datetime
#  reason_code :string
#  author_id   :integer
#  subject_id  :integer
#

class ClaimStateTransition < ActiveRecord::Base

  belongs_to :claim, class_name: ::Claim::BaseClaim, foreign_key: :claim_id
  belongs_to :author, class_name: User, foreign_key: :author_id
  belongs_to :subject, class_name: User, foreign_key: :subject_id

  def reason
    ClaimStateTransitionReason.get(reason_code)
  end

  def self.decided_this_month
    self.where{ (to == state.to_s) & (created_at >= Time.now.beginning_of_month) }.count('DISTINCT claim_id')
  end
end
