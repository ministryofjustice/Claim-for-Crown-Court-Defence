require 'rails_helper'
require File.dirname(__FILE__) + '/validation_helpers'

describe 'ExpenseV1Validator and ExpenseV2Validator' do

  include ValidationHelpers

  let(:claim)                       { FactoryGirl.build :claim, force_validation: true }
  let(:expense)                     { FactoryGirl.build :expense, claim: claim, expense_type: build(:expense_type) }
  let(:car_travel_expense)          { build(:expense, :car_travel, claim: claim ) }
  let(:parking_expense)             { build(:expense, :parking, claim: claim ) }
  let(:hotel_accommodation_expense) { build(:expense, :hotel_accommodation, claim: claim) }
  let(:train_expense)               { build(:expense, :train, claim: claim) }
  let(:travel_time_expense)         { build(:expense, :travel_time, claim: claim) }
  let(:other_expense)               { build(:expense, :other, claim: claim) }

  context 'schema_version 2' do

    before(:each) { allow(Settings).to receive(:expense_schema_version).and_return(2) }

    describe '#validate_claim' do
      it { should_error_if_not_present(expense, :claim, 'blank') }
    end

    describe '#validate_expense_type' do
      it { should_error_if_not_present(expense, :expense_type, 'blank') }
    end

    describe '#validate_quantity' do
      it { should_be_valid_if_equal_to_value(expense, :quantity, 0) }
      it { should_error_if_equal_to_value(expense, :quantity, -1,   'numericality') }
      it { should_error_if_equal_to_value(expense, :quantity, nil,  "blank") }
    end

    describe '#validate_rate' do
      it { should_be_valid_if_equal_to_value(expense, :rate, 0) }
      it { should_error_if_equal_to_value(expense, :rate, -1,   'numericality') }
      it { should_error_if_equal_to_value(expense, :rate, nil,  'blank') }
    end

    describe '#validate_location' do
      it 'should be mandatory for everything except parking' do
        [car_travel_expense, hotel_accommodation_expense, train_expense, travel_time_expense].each do |ex|
          ex.location = nil
          expect(ex.valid?).to be false
          expect(ex.errors[:location]).to include('blank')
        end
      end

      it 'should be valid when a location specified for everything except parking' do
        [car_travel_expense, hotel_accommodation_expense, train_expense, travel_time_expense].each do |ex|
          ex.location = 'Somewhere'
          expect(ex).to be_valid
        end
      end

      it 'enforces absence for parking' do
        parking_expense.location = "Somewhere"
        expect(parking_expense.valid?).to be false
        expect(parking_expense.errors[:location]).to include 'invalid'
      end

      it 'is valid when empty for parking' do
        parking_expense.location = nil
        expect(parking_expense).to be_valid
      end
    end

    describe '#validate_reason_id' do
      it 'should be valid with values 1-5 for reason set A' do
        (1..5).each do |i|
          expense.expense_type.reason_set = 'A'
          expense.reason_id = i
          expect(expense).to be_valid
        end
      end
      it 'should be invalid with values 6 and above for reason set A' do
        [0, 6, 22].each do |i|
          expense.expense_type.reason_set = 'B'
          expense.reason_id = i
          expect(expense.valid?).to be false
          expect(expense.errors[:reason_id]).to include('invalid')
        end
      end
      
      it 'should be valid with values 1-4 for reason set B' do
        (1..4).each do |i|
          expense.expense_type.reason_set = 'A'
          expense.reason_id = i
          expect(expense).to be_valid
        end
      end

      it 'should be invalid with values 5 and above for reason set B' do
        [0, 5, 15].each do |i|
          expense.expense_type.reason_set = 'B'
          expense.reason_id = i
          expect(expense.valid?).to be false
          expect(expense.errors[:reason_id]).to include('invalid')
        end
      end
    end

    describe '#validate distance' do
      context 'valid' do
        
        it 'is valid when present for car travel' do
          car_travel_expense.distance = 33
          expect(car_travel_expense).to be_valid
        end

        it 'is valid when present for train' do
          train_expense.distance = 33
          expect(train_expense).to be_valid
        end

        it 'is valid when absent for parking' do
          parking_expense.distance = nil
          expect(parking_expense).to be_valid
        end

        it 'is valid when absent for hotel' do
          hotel_accommodation_expense.distance = nil
          expect(hotel_accommodation_expense).to be_valid
        end
      end

      context 'invalid' do
        it 'is invalid when absent for car travel' do
          car_travel_expense.distance = nil
          expect(car_travel_expense).not_to be_valid
          expect(car_travel_expense.errors[:distance]).to include('blank')
        end

        it 'is invalid when zero for car travel' do
          car_travel_expense.distance = 0
          expect(car_travel_expense).not_to be_valid
          expect(car_travel_expense.errors[:distance]).to include('zero')
        end

        it 'is invalid when absent for train' do
          train_expense.distance = nil
          expect(train_expense).not_to be_valid
          expect(train_expense.errors[:distance]).to include('blank')
        end

        it 'is invalid when zero for train' do
          train_expense.distance = 0
          expect(train_expense).not_to be_valid
          expect(train_expense.errors[:distance]).to include('zero')
        end

        it 'is invalid when present for parking' do
          parking_expense.distance = 34
          expect(parking_expense).not_to be_valid
          expect(parking_expense.errors[:distance]).to include('invalid')
        end

        it 'is invalid when present for hotel' do
          hotel_accommodation_expense.distance = 44
          expect(hotel_accommodation_expense).not_to be_valid
          expect(hotel_accommodation_expense.errors[:distance]).to include('invalid')        
        end
      end
    end

    describe 'validate_mileage_rate_id' do
      it 'is invalid if present for any expense type that is not car travel' do
        [parking_expense, hotel_accommodation_expense, train_expense, train_expense, other_expense].each do |ex|
          ex.mileage_rate_id = 2
          expect(ex).not_to be_valid
          expect(ex.errors[:mileage_rate_id]).to include('invalid')
        end
      end

      it 'is invalid if not a value in the settings for car travel' do
        car_travel_expense.mileage_rate_id = 3
        expect(car_travel_expense).not_to be_valid
        expect(ex.car_travel_expense[:mileage_rate_id]).to include('invalid')
      end

      it 'is valid if present for car travel' do
        [1, 2].each do |i|
          car_travel_expense.mileage_rate_id = i
          expect(car_travel_expense).to be_valid
        end
      end

      
    end
  end

  context 'schema_version 1' do

    before(:each) { allow(Settings).to receive(:expense_schema_version).and_return(1) }

    describe '#validate_claim' do
      it { should_error_if_not_present(expense, :claim, 'blank') }
    end

    describe '#validate_expense_type' do
      it { should_error_if_not_present(expense, :expense_type, 'blank') }
    end

    describe '#validate_quantity' do
      it { should_be_valid_if_equal_to_value(expense, :quantity, 0) }
      it { should_error_if_equal_to_value(expense, :quantity, -1,   'numericality') }
      it { should_error_if_equal_to_value(expense, :quantity, nil,  "blank") }
    end

    describe '#validate_rate' do
      it { should_be_valid_if_equal_to_value(expense, :rate, 0) }
      it { should_error_if_equal_to_value(expense, :rate, -1,   'numericality') }
      it { should_error_if_equal_to_value(expense, :rate, nil,  'blank') }
    end
  end

end

