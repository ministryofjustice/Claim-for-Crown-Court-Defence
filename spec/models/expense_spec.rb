# == Schema Information
#
# Table name: expenses
#
#  id              :integer          not null, primary key
#  expense_type_id :integer
#  claim_id        :integer
#  location        :string
#  quantity        :integer
#  rate            :decimal(, )
#  amount          :decimal(, )
#  created_at      :datetime
#  updated_at      :datetime
#  uuid            :uuid
#

require 'rails_helper'

RSpec.describe Expense, type: :model do

  it { should belong_to(:expense_type) }
  it { should belong_to(:claim) }
  it { should have_many(:dates_attended) }

  it { should validate_presence_of(:claim).with_message('blank') }

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

  describe 'comma formatted inputs' do
    [:rate, :quantity, :amount].each do |attribute|
      it "converts input for #{attribute} by stripping commas out" do
        expense = build(:expense)
        expense.send("#{attribute}=", '12,321,111')
        expect(expense.send(attribute)).to eq(12321111)
      end
    end
  end
end
