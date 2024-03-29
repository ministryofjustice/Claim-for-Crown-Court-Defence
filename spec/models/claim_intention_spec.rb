# == Schema Information
#
# Table name: claim_intentions
#
#  id         :integer          not null, primary key
#  form_id    :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :integer
#

require 'rails_helper'

RSpec.describe ClaimIntention do
  it { should validate_presence_of(:form_id) }
  it { should validate_uniqueness_of(:form_id).with_message('There is already a claim with this form-id') }
end
