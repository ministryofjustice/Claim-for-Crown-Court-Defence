require 'rails_helper'

RSpec.describe Court, type: :model do
  it { should have_many(:claims) }

  it { should validate_presence_of(:code) }
  it { should validate_uniqueness_of(:code) }
  it { should validate_presence_of(:name) }
  it { should validate_uniqueness_of(:name) }
  it { should validate_presence_of(:court_type) }
  it { should validate_inclusion_of(:court_type).in_array(%w( crown magistrate )) }
end
