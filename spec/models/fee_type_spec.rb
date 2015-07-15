# == Schema Information
#
# Table name: fee_types
#
#  id                :integer          not null, primary key
#  description       :string(255)
#  code              :string(255)
#  fee_category_id   :integer
#  created_at        :datetime
#  updated_at        :datetime
#  quantity_modifier :integer
#

require 'rails_helper'

RSpec.describe FeeType, type: :model do

  let (:basic) { create :basic_fee_category }
  let (:basic_fee_type) { create :fee_type, fee_category: basic }

  it { should belong_to(:fee_category) }
  it { should have_many(:fees) }
  it { should have_many(:claims) }

  it { should validate_presence_of(:fee_category) }
  it { should validate_presence_of(:description) }
  it { should validate_presence_of(:code) }
  it { should validate_uniqueness_of(:description) }

  it { should respond_to(:code) }
  it { should respond_to(:description) }
  it { should respond_to(:quantity_modifier) }

  describe '.basic' do
    it 'should return fee types belonging to category basic only' do
      basic_c = FactoryGirl.create :fee_type, fee_category: basic, description: 'Basic fee type C'
      basic_a = FactoryGirl.create :fee_type, fee_category: basic, description: 'Basic fee type A'
      basic_b = FactoryGirl.create :fee_type, fee_category: basic, description: 'Basic fee type B'

      expect(FeeType.basic).to eq( [ basic_a, basic_b, basic_c ] )
    end
  end

end
