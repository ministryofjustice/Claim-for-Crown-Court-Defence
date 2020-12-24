# == Schema Information
#
# Table name: disbursement_types
#
#  id          :integer          not null, primary key
#  name        :string
#  created_at  :datetime
#  updated_at  :datetime
#  deleted_at  :datetime
#  unique_code :string
#

require 'rails_helper'

RSpec.describe DisbursementType, type: :model do
  it { should have_many(:disbursements) }

  it { should validate_presence_of(:name) }
  it { should validate_uniqueness_of(:name).ignoring_case_sensitivity.with_message('A disbursement type of this name already exists') }
  it { should validate_presence_of(:unique_code) }
  it { should validate_uniqueness_of(:unique_code).ignoring_case_sensitivity.with_message('A disbursement type with this unique code already exists') }

  context 'scopes' do
    before(:all) do
      create :disbursement_type, name: 'Zebras'
      create :disbursement_type, name: 'Travel Costs', deleted_at: 3.minutes.ago
      create :disbursement_type, name: 'Aardvarks'
    end

    after(:all) { DisbursementType.delete_all }

    describe 'default scope' do
      it 'returns in alphabetical order by name' do
        expect(DisbursementType.all.map(&:name)).to eq(['Aardvarks', 'Travel Costs', 'Zebras'])
      end
    end

    describe 'active scope' do
      it 'excludes records with non-nil deleted_at' do
        expect(DisbursementType.active.map(&:name)).to eq(['Aardvarks', 'Zebras'])
      end
    end
  end
end
