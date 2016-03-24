# == Schema Information
#
# Table name: expenses
#
#  id              :integer          not null, primary key
#  expense_type_id :integer
#  claim_id        :integer
#  location        :string
#  quantity        :float
#  rate            :decimal(, )
#  amount          :decimal(, )
#  created_at      :datetime
#  updated_at      :datetime
#  uuid            :uuid
#  reason_id       :integer
#  reason_text     :string
#  schema_version  :integer
#  distance        :integer
#  mileage_rate_id :integer
#  date            :date
#  hours           :integer
#

require 'rails_helper'

RSpec.describe Expense, type: :model do

  it { should belong_to(:expense_type) }
  it { should belong_to(:claim) }
  it { should have_many(:dates_attended) }

  it { should validate_presence_of(:claim).with_message('blank') }

  describe 'delegated methods' do
    let(:expense_type) { subject.expense_type }

    subject { build :expense, :car_travel }

    [:car_travel?, :parking?, :hotel_accommodation?, :train?, :travel_time?].each do |method|
      it "delegates #{method} to expense_type" do
        expect(expense_type).to receive(method)
        subject.send(method)
      end
    end
  end

  context 'expense_reasons and expense reason text' do
    let(:ex_1) { build :expense, reason_id: 1 }
    let(:ex_nil) { build :expense, reason_id: nil }
    let(:ex_5) { build :expense, reason_id: 5, reason_text: 'My unique reason' }

    describe '#expense reason' do
      it 'returns the reason object with id 1' do
        expect(ex_1.expense_reason).to be_instance_of(ExpenseReason)
        expect(ex_1.expense_reason.id).to eq 1
      end

      it 'returns nil if reason_id not set' do
        expect(ex_nil.expense_reason).to be_nil
      end
    end

    describe '#allow_reason_text' do
      it 'returns false if no reason id' do
        expect(ex_nil.allow_reason_text?).to be false
      end
      it 'returns false for reason id 1' do
        expect(ex_1.allow_reason_text?).to be false
      end
      it 'returns true for reason id 5' do
        expect(ex_5.allow_reason_text?).to be true
      end
    end

    describe '#displayable_reason_text' do
      it 'returns nil if reason id is nil' do
        expect(ex_nil.displayable_reason_text).to be_nil
      end

      it 'returns reason from reason text' do
        expect(ex_1.displayable_reason_text).to eq 'Court hearing'
      end

      it 'returns the reason_text from the record for reason id 5' do
        expect(ex_5.displayable_reason_text).to eq "My unique reason"
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
