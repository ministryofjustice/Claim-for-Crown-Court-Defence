# == Schema Information
#
# Table name: expenses
#
#  id              :integer          not null, primary key
#  expense_type_id :integer
#  claim_id        :integer
#  date            :datetime
#  location        :string(255)
#  quantity        :integer
#  rate            :decimal(, )
#  amount          :decimal(, )
#  created_at      :datetime
#  updated_at      :datetime
#

require 'rails_helper'

RSpec.describe Expense, type: :model do
  it { should belong_to(:expense_type) }
  it { should belong_to(:claim) }

  it { should validate_presence_of(:expense_type) }
  it { should validate_presence_of(:claim) }
  it { should validate_presence_of(:quantity) }
  it { should validate_numericality_of(:quantity).is_greater_than_or_equal_to(0) }
  it { should validate_presence_of(:rate) }
  it { should validate_numericality_of(:rate).is_greater_than_or_equal_to(0) }

  describe 'set and update amount' do
    subject { build(:expense, rate: 2.5, quantity: 3, amount: 0) }

    context 'for a new expense' do
      it 'sets the expense amount equal to rate x quantity' do
        subject.save!
        expect(subject.amount).to eq(7.5)
      end
    end

    context 'for an existing' do
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
