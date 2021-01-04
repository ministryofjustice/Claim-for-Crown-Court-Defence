# == Schema Information
#
# Table name: courts
#
#  id         :integer          not null, primary key
#  code       :string
#  name       :string
#  court_type :string
#  created_at :datetime
#  updated_at :datetime
#

require 'rails_helper'

RSpec.describe Court, type: :model do
  it { should have_many(:claims) }

  it { should validate_presence_of(:code) }
  it { should validate_uniqueness_of(:code).with_message('Court code must be unique') }
  it { should validate_presence_of(:name) }
  it { should validate_uniqueness_of(:name).with_message('Court name must be unique') }
  it { should validate_presence_of(:court_type) }
  it { should validate_inclusion_of(:court_type).in_array(%w(crown magistrate)) }

  describe '.alphabetical' do
    let(:court_1) { create(:court, name: 'Oxford') }
    let(:court_2) { create(:court, name: 'Reading') }
    let(:court_3) { create(:court, name: 'Cambridge') }

    it 'returns the courts in alphabetical order' do
      expect(Court.alphabetical).to eq([court_3, court_1, court_2])
    end
  end
end
