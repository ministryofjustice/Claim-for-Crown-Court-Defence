# == Schema Information
#
# Table name: locations
#
#  id         :integer          not null, primary key
#  name       :string
#  created_at :datetime
#  updated_at :datetime
#

require 'rails_helper'

RSpec.describe Location, type: :model do
  it { should have_many(:case_workers) }

  it { should validate_presence_of(:name) }
  it { is_expected.to validate_uniqueness_of(:name).ignoring_case_sensitivity.with_message('This location already exists') }

  describe '#to_s' do
    subject { build(:location) }
    it 'returns the location name' do
      expect(subject.to_s).to eq(subject.name)
    end
  end
end
