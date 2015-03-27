require 'rails_helper'

RSpec.describe Chamber, type: :model do
  it { should have_many(:advocates).conditions(role: 'advocate') }

  it { should validate_presence_of(:name) }
  it { should validate_uniqueness_of(:name) }
end
