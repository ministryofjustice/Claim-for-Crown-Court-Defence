# == Schema Information
#
# Table name: fees
#
#  id          :integer          not null, primary key
#  claim_id    :integer
#  fee_type_id :integer
#  quantity    :integer
#  rate        :decimal(, )
#  amount      :decimal(, )
#  created_at  :datetime
#  updated_at  :datetime
#

require 'rails_helper'

RSpec.describe Fee, type: :model do
  it { should belong_to(:claim) }
  it { should belong_to(:fee_type) }
  it { should have_many(:dates_attended) }

  it { should validate_presence_of(:fee_type) }
  it { should validate_presence_of(:quantity) }
  it { should validate_numericality_of(:quantity).is_greater_than_or_equal_to(0) }
  it { should validate_presence_of(:rate) }
  it { should validate_numericality_of(:rate).is_greater_than_or_equal_to(0) }

  it { should accept_nested_attributes_for(:dates_attended) }

  describe 'set and update amount' do
    subject { build(:fee, rate: 2.5, quantity: 3, amount: 0) }

    context 'for a new fee' do
      it 'sets the fee amount equal to rate x quantity' do
        subject.save!
        expect(subject.amount).to eq(7.5)
      end
    end

    context 'for an existing fee' do
      before do
        subject.save!
        subject.rate = 3;
        subject.save!
      end

      it 'updates the amount to be equal to the new rate x quantity' do
        expect(subject.amount).to eq(9.0)
      end
    end
  end
end
