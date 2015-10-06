require 'rails_helper'

RSpec.describe ClaimIntention, type: :model do
  it { should validate_presence_of(:form_id) }
  it { should validate_uniqueness_of(:form_id) }
end
