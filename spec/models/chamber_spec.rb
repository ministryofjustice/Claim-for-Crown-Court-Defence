require 'rails_helper'

RSpec.describe Chamber, type: :model do
  it { should have_many(:advocates) }
  it { should have_many(:claims) }

  it { should validate_presence_of(:name) }
  it { should validate_uniqueness_of(:name) }
  it { should validate_presence_of(:account_number) }
  it { should validate_uniqueness_of(:account_number) }
end
