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

  let(:car_travel_expense)          { build(:expense, expense_type: build(:expense_type, name: 'Car travel')) }
  let(:parking_expense)             { build(:expense, expense_type: build(:expense_type, name: 'Parking')) }
  let(:hotel_accommodation_expense) { build(:expense, expense_type: build(:expense_type, name: 'Hotel accommodation')) }
  let(:train_expense)               { build(:expense, expense_type: build(:expense_type, name: 'Train/public_transport')) }
  let(:travel_time_expense)         { build(:expense, expense_type: build(:expense_type, name: 'Travel time')) }


  it { should belong_to(:expense_type) }
  it { should belong_to(:claim) }
  it { should have_many(:dates_attended) }

  it { should validate_presence_of(:claim).with_message('blank') }

  describe 'predicate methods' do
    it 'returns true for the type of expense it is' do
      expect(car_travel_expense.car_travel?).to be true
      expect(car_travel_expense.train?).to be false

      expect(parking_expense.parking?).to be true
      expect(parking_expense.car_travel?).to be false

      expect(hotel_accommodation_expense.hotel_accommodation?).to be true
      expect(hotel_accommodation_expense.parking?).to be false

      expect(train_expense.train?).to be true
      expect(train_expense.hotel_accommodation?).to be false

      expect(travel_time_expense.travel_time?).to be true
      expect(travel_time_expense.train?).to be false
    end
  end

  context 'schema_version' do
    context 'expense_schema_version_1' do
      
      before(:each) { allow(Settings).to receive(:expense_schema_version).and_return(1) }
      
      it 'should create new records with 1' do
        expense = create :expense
        expect(expense.schema_version).to eq 1
      end

      it 'uses V1 validator' do
        expense = build :expense
        expect_any_instance_of(ExpenseV1Validator).to receive(:validate)
        expect_any_instance_of(ExpenseV2Validator).not_to receive(:validate)
        expense.valid?
      end
    end

    context 'expense_schema_version_2' do
      it 'creates new records with version 2' do
        allow(Settings).to receive(:expense_schema_version).and_return(2)
        expense = create :expense
        expect(expense.schema_version).to eq 2
      end

      it 'does not change the version number on an existing record with version 1' do
        allow(Settings).to receive(:expense_schema_version).and_return(1)
        expense = create :expense
        expect(expense.schema_version).to eq 1
        allow(Settings).to receive(:expense_schema_version).and_return(2)
        expense.update(location: 'Ambridge')
        expense.reload
        expect(expense.location).to eq 'Ambridge'
        expect(expense.schema_version).to eq 1
      end

      it 'uses V2 validator' do
        allow(Settings).to receive(:expense_schema_version).and_return(2)
        expense = build :expense
        expect_any_instance_of(ExpenseV2Validator).to receive(:validate)
        expect_any_instance_of(ExpenseV1Validator).not_to receive(:validate)
        expense.valid?
      end
    end

    context 'validation' do
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

    describe '#reason_text' do
      it 'returns nil if reason id is nil' do
        expect(ex_nil.reason_text).to be_nil
      end

      it 'returns reason from reason text' do
        expect(ex_1.reason_text).to eq 'Court hearing'
      end

      it 'returns the reason_text from the record for reason id 5' do
        expect(ex_5.reason_text).to eq "My unique reason"
      end
    end
  end

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

  describe '#quantity' do
    it 'is rounded to the nearest quarter, in a before save hook, if a float is entered' do
      subject = build(:expense, rate: 10, quantity: 1.1, amount: 0)
      expect(subject.quantity).to eq 1.1
      subject.save!
      expect(subject.quantity).to eq 1.0      
    end
  end

end
