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

require 'rails_helper'

RSpec.describe ClaimStateTransition, type: :model do
  it { should belong_to :claim }
end
