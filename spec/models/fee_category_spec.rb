require 'rails_helper'

RSpec.describe FeeCategory, type: :model do
  it { should have_many(:fees) }

  it { should validate_presence_of(:name) }
  it { should validate_uniqueness_of(:name) }
end
