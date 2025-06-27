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

class ClaimStateTransition < ApplicationRecord
  belongs_to :claim, class_name: '::Claim::BaseClaim'
  belongs_to :author, class_name: 'User'
  belongs_to :subject, class_name: 'User'

  serialize :reason_code, type: Array
  alias_attribute :reason_codes, :reason_code

  def reason
    if reason_code.is_a?(Array)
      reasons
    else
      [] << ClaimStateTransitionReason.get(reason_code)
    end
  end

  def reasons
    reason_code.reject(&:empty?).map { |reason_code| ClaimStateTransitionReason.get(reason_code) }
  end

  def self.decided_this_month(state)
    where(to: state.to_s).where(
      arel_table[:created_at].gteq(Time.zone.now.beginning_of_month)
    ).count('DISTINCT claim_id')
  end

  def update_author_id(value)
    self.author_id = value
    save!
  end

  def author_name
    author&.name
  end
end
