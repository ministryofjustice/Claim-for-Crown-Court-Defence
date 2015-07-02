require 'rails_helper'

RSpec.describe Location, type: :model do
  it { should have_many(:case_workers) }

  it { should validate_presence_of(:name) }
  it { should validate_uniqueness_of(:name) }

  describe '#to_s' do
    subject { build(:location) }
    it 'returns the location name' do
      expect(subject.to_s).to eq(subject.name)
    end
  end
end
