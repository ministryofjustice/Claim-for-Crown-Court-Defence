# == Schema Information
#
# Table name: claim_state_transitions
#
#  id         :integer          not null, primary key
#  claim_id   :integer
#  namespace  :string(255)
#  event      :string(255)
#  from       :string(255)
#  to         :string(255)
#  created_at :datetime
#

class ClaimStateTransition < ActiveRecord::Base
  belongs_to :claim
end
