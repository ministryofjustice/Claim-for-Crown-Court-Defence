# == Schema Information
#
# Table name: claim_state_transitions
#
#  id         :integer          not null, primary key
#  claim_id   :integer
#  namespace  :string
#  event      :string
#  from       :string
#  to         :string
#  created_at :datetime
#

class ClaimStateTransition < ActiveRecord::Base

  belongs_to :claim, class_name: ::Claim::BaseClaim, foreign_key: :claim_id
end
