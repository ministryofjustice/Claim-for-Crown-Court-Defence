# == Schema Information
#
# Table name: chambers
#
#  id              :integer          not null, primary key
#  name            :string
#  supplier_number :string
#  vat_registered  :boolean
#  created_at      :datetime
#  updated_at      :datetime
#  uuid            :uuid
#  api_key         :uuid
#

require 'rails_helper'

RSpec.describe Chamber, type: :model do
  it { should have_many(:advocates) }
  it { should have_many(:claims) }

  it { should validate_presence_of(:name) }
  it { should validate_uniqueness_of(:name) }
  it { should validate_presence_of(:supplier_number) }
  it { should validate_uniqueness_of(:supplier_number) }

  context '.set_api_key' do
    let(:chamber) { FactoryGirl.create(:chamber) }

    it 'should set API key at creation' do
      expect(chamber.api_key.present?).to eql true
    end

    it 'should set API key before validation' do
      chamber.api_key = nil
      expect(chamber.api_key.present?).to eql false
      expect(chamber).to be_valid
      expect(chamber.api_key.present?).to eql true
    end
  end

  context '.regenerate_api_key' do
    let(:chamber) { FactoryGirl.create(:chamber) }

    it 'should create a new api_key' do
      old_api_key = chamber.api_key
      expect{ chamber.regenerate_api_key! }.to change{ chamber.api_key }.from(old_api_key)
    end
  end

end
