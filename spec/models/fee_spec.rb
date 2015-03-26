require 'rails_helper'

RSpec.describe Fee, type: :model do
  it { should belong_to(:fee_type) }

  it { should validate_presence_of(:fee_type) }
  it { should validate_presence_of(:description) }
  it { should validate_presence_of(:code) }
  it { should validate_uniqueness_of(:description) }
  it { should validate_uniqueness_of(:code) }
end
