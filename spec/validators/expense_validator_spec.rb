require 'rails_helper'
require File.dirname(__FILE__) + '/validation_helpers'

describe 'ExpenseV1Validator and ExpenseV2Validator' do

  include ValidationHelpers

  context 'schema_version 2' do

    let(:claim)                       { build :claim, force_validation: true }
    let(:expense)                     { build :expense, :train, claim: claim }
    let(:car_travel_expense)          { build(:expense, :car_travel, claim: claim ) }
    let(:parking_expense)             { build(:expense, :parking, claim: claim ) }
    let(:hotel_accommodation_expense) { build(:expense, :hotel_accommodation, claim: claim) }
    let(:train_expense)               { build(:expense, :train, claim: claim) }
    let(:road_tolls_expense)          { build(:expense, :road_tolls, claim: claim) }
    let(:cab_fares_expense)           { build(:expense, :cab_fares, claim: claim) }
    let(:subsistence_expense)         { build(:expense, :subsistence, claim: claim) }
    let(:travel_time_expense)         { build(:expense, :travel_time, claim: claim) }
    let(:other_reason_type_expense)   { build(:expense, :train, claim: claim, reason_id: 5)}

    before(:each) { allow(Settings).to receive(:expense_schema_version).and_return(2) }

    it { should_error_if_equal_to_value(expense, :amount, 200_001, 'item_max_amount') }

    describe '#validate_vat_amount for AGFS claims' do
      it 'is valid if absent' do
        expense.vat_amount = nil
        expect(expense).to be_valid
      end

      it 'is valid if blank' do
        expense.vat_amount = ''
        expect(expense).to be_valid
      end

      it 'is valid if zero' do
        expense.vat_amount = 0
        expect(expense).to be_valid
      end

      it 'is invalid if any other value' do
        expense.vat_amount = 3
        expect(expense).not_to be_valid
        expect(expense.errors[:vat_amount]).to include('invalid')
      end
    end

    describe '#validate_vat_amount for LGFS claims' do
      let(:claim) { build :litigator_claim, force_validation: true }

      it { should_error_if_equal_to_value(expense, :vat_amount, 200_001, 'item_max_amount') }

      it 'is valid if absent' do
        expense.vat_amount = nil
        expect(expense).to be_valid
      end

      it 'is valid if blank' do
        expense.vat_amount = ''
        expect(expense).to be_valid
      end

      it 'is valid if zero' do
        expense.vat_amount = 0
        expect(expense).to be_valid
      end

      it 'is valid if less than the total amount' do
        expense.amount = 11
        expense.vat_amount = 10.5
        expect(expense).to be_valid
      end

      it 'is invalid if greater than the total amount' do
        expense.amount = 11
        expense.vat_amount = 11.5
        expect(expense).not_to be_valid
        expect(expense.errors[:vat_amount]).to include('greater_than')
      end

      it 'is invalid if negative' do
        expense.vat_amount = -5
        expect(expense).not_to be_valid
        expect(expense.errors[:vat_amount]).to include('numericality')
      end
    end

    describe '#validate_date' do
      it 'is valid for todays date' do
        expense.date = Date.today
        expect(expense).to be_valid
      end

      it 'is valid for dates in the past' do
        expense.date = 10.days.ago
        expect(expense).to be_valid
      end

      it 'is invalid for dates too far in the past' do
        should_error_if_too_far_in_the_past(expense, :date, 'check_not_too_far_in_past')
      end

      it 'is invalid for dates in the future' do
        should_error_if_in_future(expense, :date, 'future')
      end

      it 'is invalid if absent' do
        expense.date = nil
        expect(expense).not_to be_valid
        expect(expense.errors[:date]).to include('blank')
      end
    end

    describe '#validate_hours' do
      context 'travel time' do
        it 'is invalid if absent' do
          travel_time_expense.hours = nil
          expect(travel_time_expense).not_to be_valid
          expect(travel_time_expense.errors[:hours]).to include('blank')
        end

        it 'is invalid if zero' do
          travel_time_expense.hours = 0
          expect(travel_time_expense).not_to be_valid
          expect(travel_time_expense.errors[:hours]).to include('numericality')
        end

        it 'is invalid if negative' do
          travel_time_expense.hours = -5
          expect(travel_time_expense).not_to be_valid
          expect(travel_time_expense.errors[:hours]).to include('numericality')
        end

        it 'is valid if present and above zero' do
          travel_time_expense.hours = 1.5
          expect(travel_time_expense).to be_valid
        end
      end

      context 'not travel time' do
        let(:expenses_to_test) { [car_travel_expense, parking_expense, hotel_accommodation_expense, train_expense, road_tolls_expense, cab_fares_expense, subsistence_expense] }

        it 'is invalid if present' do
          expenses_to_test.each do |ex|
            ex.hours = 5
            expect(ex).not_to be_valid
            expect(ex.errors[:hours]).to include('invalid')
          end
        end

        it 'is valid if absent' do
          expenses_to_test.each do |ex|
            ex.hours = nil
            expect(ex).to be_valid
          end
        end
      end
    end

    describe 'reason_text' do
      context 'other reason types' do
        it 'should be valid if present' do
          other_reason_type_expense.reason_text = 'my reasons'
          expect(other_reason_type_expense).to be_valid
        end

        it 'should be invalid if absent' do
          other_reason_type_expense.reason_text = nil
          expect(other_reason_type_expense).not_to be_valid
          expect(other_reason_type_expense.errors[:reason_text]).to include('blank_for_other')
        end
      end
    end

    describe '#validate_claim' do
      it { should_error_if_not_present(expense, :claim, 'blank') }
    end

    describe '#validate_expense_type' do
      it { should_error_if_not_present(expense, :expense_type, 'blank') }
    end

    describe '#validate_location' do
      let(:expenses_to_test) { [car_travel_expense, hotel_accommodation_expense, train_expense, road_tolls_expense, cab_fares_expense, subsistence_expense] }

      it 'should be mandatory for everything except parking and travel time ' do
        expenses_to_test.each do |ex|
          ex.location = nil
          expect(ex.valid?).to be false
          expect(ex.errors[:location]).to include('blank')
        end
      end

      it 'should be valid when a location specified for everything except parking and travel time' do
        expenses_to_test.each do |ex|
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
      it 'should be valid with values 1-4 for reason set A' do
        (1..4).each do |i|
          expense.expense_type.reason_set = 'A'
          expense.reason_id = i
          expense.reason_text = "xxx" if expense.expense_reason_other?
          expect(expense).to be_valid
        end
      end

      it 'should be valid with value 5 for reason set A with reason text filled' do
        expense.expense_type.reason_set = 'A'
        expense.reason_id = 5
        expense.reason_text = 'blah'
        expect(expense).to be_valid
      end

      it 'should be invalid with value 5 for reason set A without reason text filled' do
        expense.expense_type.reason_set = 'A'
        expense.reason_id = 5
        expect(expense).not_to be_valid
        expect(expense.errors[:reason_text]).to include('blank_for_other')
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

    describe '#validate_reason_text' do
      context 'validates presence when reason ID is 5 for reason set A' do
        before do
          expense.expense_type.reason_set = 'A'
          expense.reason_id = 5
        end

        it 'reason text is present' do
          expense.reason_text = 'blah'
          expense.valid?
          expect(expense).to be_valid
        end

        it 'reason text is not present' do
          expense.valid?
          expect(expense).not_to be_valid
          expect(expense.errors[:reason_text]).to include('blank_for_other')
        end
      end

      context 'validates absence when reason ID is other than 5 regardless of the reason set' do
        before do
          expense.reason_id = 3
        end

        it 'reason text is present' do
          expense.reason_text = 'blah'
          expense.valid?
          expect(expense).not_to be_valid
          expect(expense.errors[:reason_text]).to include('invalid')
        end

        it 'reason text is not present' do
          expense.valid?
          expect(expense).to be_valid
        end
      end
    end

    describe '#validate distance' do
      context 'valid' do

        it 'is valid when present for car travel' do
          car_travel_expense.distance = 33
          expect(car_travel_expense).to be_valid
        end

        it 'is valid when distance is decimal' do
          car_travel_expense.distance = 30.52
          expect(car_travel_expense).to be_valid
        end

        it 'is valid when absent for train' do
          train_expense.distance = nil
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
          expect(car_travel_expense.errors[:distance]).to include('numericality')
        end

        it 'is invalid when negative for car travel' do
          car_travel_expense.distance = -5
          expect(car_travel_expense).not_to be_valid
          expect(car_travel_expense.errors[:distance]).to include('numericality')
        end

        it 'is invalid when present for train' do
          train_expense.distance = 33
          expect(train_expense).not_to be_valid
          expect(train_expense.errors[:distance]).to include('invalid')
        end

        it 'is invalid when zero for train' do
          train_expense.distance = 0
          expect(train_expense).not_to be_valid
          expect(train_expense.errors[:distance]).to include('invalid')
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
      context 'not car travel' do
        let(:expenses_to_test) { [parking_expense, travel_time_expense, hotel_accommodation_expense, train_expense, road_tolls_expense, cab_fares_expense, subsistence_expense] }

        it 'is invalid if present' do
          expenses_to_test.each do |ex|
            ex.mileage_rate_id = 2
            expect(ex).not_to be_valid
            expect(ex.errors[:mileage_rate_id]).to include('invalid')
          end
        end

        it 'is valid when absent' do
          expenses_to_test.each do |ex|
            ex.mileage_rate_id = nil
            expect(ex).to be_valid
          end
        end
      end

      context 'car travel' do
        it 'is invalid if not a value in the settings' do
          car_travel_expense.mileage_rate_id = 3
          expect(car_travel_expense).not_to be_valid
          expect(car_travel_expense.errors[:mileage_rate_id]).to include('invalid')
        end

        it 'is valid if present for car travel' do
          [1, 2].each do |i|
            car_travel_expense.mileage_rate_id = i
            expect(car_travel_expense).to be_valid
          end
        end

        it 'is invalid if absent' do
          car_travel_expense.mileage_rate_id = nil
          expect(car_travel_expense).not_to be_valid
          expect(car_travel_expense.errors[:mileage_rate_id]).to include('blank')
        end
      end

    end
  end

  context 'schema_version 1' do

    let(:claim)      { FactoryGirl.build :claim, force_validation: true }
    let(:expense)    { FactoryGirl.build :expense, claim: claim, expense_type: build(:expense_type) }

    before(:each) { allow(Settings).to receive(:expense_schema_version).and_return(1) }

    describe '#validate_claim' do
      it { should_error_if_not_present(expense, :claim, 'blank') }
    end
  end
end



