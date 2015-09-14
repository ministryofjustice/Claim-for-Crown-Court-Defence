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

require 'rails_helper'

RSpec.describe ClaimStateTransition, type: :model do
  it { should belong_to :claim }
end
