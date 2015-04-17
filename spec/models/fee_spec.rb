require 'rails_helper'

RSpec.describe Fee, type: :model do
  it { should belong_to(:claim) }
  it { should belong_to(:fee_type) }
end
