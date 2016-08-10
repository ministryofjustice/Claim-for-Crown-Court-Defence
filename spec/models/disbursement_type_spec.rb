# == Schema Information
#
# Table name: disbursement_types
#
#  id         :integer          not null, primary key
#  name       :string
#  created_at :datetime
#  updated_at :datetime
#

require 'rails_helper'

RSpec.describe DisbursementType, type: :model do

  it { should have_many(:disbursements) }

  it { should validate_presence_of(:name) }
  it { should validate_uniqueness_of(:name) }

  describe '.allowable_types' do
    let!(:travel_costs) { create(:disbursement_type, name: 'Travel costs') }

    it 'should exclude "Travel costs" from the result set' do
      expect(described_class.allowable_types).to_not include(travel_costs)
    end
  end
end
