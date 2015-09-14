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

FactoryGirl.define do
  factory :claim_state_transition do
    claim nil
namespace "MyString"
event "MyString"
from "MyString"
to "MyString"
created_at "2015-07-29 14:54:13"
  end

end
