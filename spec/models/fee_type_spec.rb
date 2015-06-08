# == Schema Information
#
# Table name: fee_types
#
#  id              :integer          not null, primary key
#  description     :string(255)
#  code            :string(255)
#  fee_category_id :integer
#  created_at      :datetime
#  updated_at      :datetime
#

require 'rails_helper'

RSpec.describe FeeType, type: :model do
  it { should belong_to(:fee_category) }
  it { should have_many(:fees) }
  it { should have_many(:claims) }

  it { should validate_presence_of(:fee_category) }
  it { should validate_presence_of(:description) }
  it { should validate_presence_of(:code) }
  it { should validate_uniqueness_of(:description) }

  describe '.basic' do
    it 'should return fee types belonging to category basic only' do
      basic   = FactoryGirl.create :basic_fee_category
      misc    = FactoryGirl.create :misc_fee_category
      misc_a  = FactoryGirl.create :fee_type, fee_category: misc, description: 'Misc fee type A'
      misc_b  = FactoryGirl.create :fee_type, fee_category: misc, description: 'Misc fee type B'
      basic_c = FactoryGirl.create :fee_type, fee_category: basic, description: 'Basic fee type C'
      basic_a = FactoryGirl.create :fee_type, fee_category: basic, description: 'Basic fee type A'
      basic_b = FactoryGirl.create :fee_type, fee_category: basic, description: 'Basic fee type B'

      expect(FeeType.basic).to eq( [ basic_a, basic_b, basic_c ] )
    end
  end
end
