require 'rails_helper'

RSpec.describe FeeCategory, type: :model do
  it { should have_many(:fee_types) }

  it { should validate_presence_of(:name) }
  it { should validate_uniqueness_of(:name) }

  it { should validate_presence_of(:abbreviation) }
  it { should validate_uniqueness_of(:abbreviation) }  
end
