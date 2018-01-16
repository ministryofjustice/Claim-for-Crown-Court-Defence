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
#  reason_text :string
#

class ClaimStateTransition < ActiveRecord::Base
  belongs_to :claim, class_name: ::Claim::BaseClaim, foreign_key: :claim_id
  belongs_to :author, class_name: User, foreign_key: :author_id
  belongs_to :subject, class_name: User, foreign_key: :subject_id

  serialize :reason_code, Array

  def reason
    if reason_code.is_a?(Array)
      reasons
    else
      [] << ClaimStateTransitionReason.get(reason_code)
    end
  end

  def reasons
    reasons = reason_code.reject(&:empty?)
    result = []
    reasons.each do |reason_code|
      result << ClaimStateTransitionReason.get(reason_code)
    end
    result
  end

  def self.decided_this_month(state)
    where { (to == state.to_s) & (created_at >= Time.now.beginning_of_month) }.count('DISTINCT claim_id')
  end

  def update_author_id(value)
    self.author_id = value
    save!
  end

  def author_name
    author&.name
  end
end
