require 'rails_helper'

RSpec.describe 'ExpenseValidator', type: :validator do
  let(:claim)                       { build(:claim) }
  let(:expense)                     { build(:expense, :train, claim:) }
  let(:car_travel_expense)          { build(:expense, :car_travel, claim:) }
  let(:bike_travel_expense)         { build(:expense, :bike_travel, claim:) }
  let(:parking_expense)             { build(:expense, :parking, claim:) }
  let(:hotel_accommodation_expense) { build(:expense, :hotel_accommodation, claim:) }
  let(:train_expense)               { build(:expense, :train, claim:) }
  let(:road_tolls_expense)          { build(:expense, :road_tolls, claim:) }
  let(:cab_fares_expense)           { build(:expense, :cab_fares, claim:) }
  let(:subsistence_expense)         { build(:expense, :subsistence, claim:) }
  let(:travel_time_expense)         { build(:expense, :travel_time, claim:) }
  let(:other_reason_type_expense)   { build(:expense, :train, claim:, reason_id: 5) }

  before do
    claim.force_validation = true
  end

  it { should_error_if_equal_to_value(expense, :amount, 200_001, 'The amount for the expense exceeds the limit') }

  describe '#validate_vat_amount for LGFS claims' do
    let(:claim) { build(:litigator_claim, force_validation: true) }

    before { expense.amount = 100 }

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
      expense.vat_amount = 10
      expect(expense).to be_valid
    end

    it 'is invalid if greater than the total amount' do
      expense.vat_amount = 100.01
      expect(expense).not_to be_valid
      expect(expense.errors[:vat_amount]).to include('greater_than')
    end

    it 'is valid if less than VAT% of total amount' do
      expense.vat_amount = 19.99
      expect(expense).to be_valid
    end

    it 'is valid if equal to VAT% of total amount' do
      expense.vat_amount = 20.00
      expect(expense).to be_valid
    end

    it 'is valid if rounded value is less than VAT% of total amount' do
      expense.vat_amount = 19.991
      expect(expense).to be_valid
    end

    it 'is valid if rounded value is equal to VAT% of total amount' do
      expense.vat_amount = 20.001
      expect(expense).to be_valid
    end

    it 'is invalid if greater than current VAT% of the total amount' do
      expense.vat_amount = 20.01
      expect(expense).not_to be_valid
      expect(expense.errors[:vat_amount]).to include('max_vat_amount')
    end

    it 'is invalid if rounded value greater than current VAT% of the total amount' do
      expense.vat_amount = 20.009
      expect(expense).not_to be_valid
      expect(expense.errors[:vat_amount]).to include('max_vat_amount')
    end

    it 'is invalid if negative' do
      expense.vat_amount = -5
      expect(expense).not_to be_valid
      expect(expense.errors[:vat_amount]).to include('numericality')
    end
  end

  describe '#validate_date' do
    it 'is valid for todays date' do
      expense.date = Time.zone.today
      expect(expense).to be_valid
    end

    it 'is valid for dates in the past' do
      expense.date = 10.days.ago
      expect(expense).to be_valid
    end

    it 'is invalid if before earliest rep order date' do
      should_error_if_earlier_than_earliest_reporder_date(claim, expense, :date, 'Check the date for the expense')
    end

    it 'is invalid for dates in the future' do
      should_error_if_in_future(expense, :date, 'Date for the expense cannot be in the future')
    end

    it 'is invalid if absent' do
      expense.date = nil
      expect(expense).not_to be_valid
      expect(expense.errors[:date]).to include('Enter a date for the expense')
    end
  end

  describe '#validate_hours' do
    context 'travel time' do
      it 'is invalid if absent' do
        travel_time_expense.hours = nil
        expect(travel_time_expense).not_to be_valid
        expect(travel_time_expense.errors[:hours]).to include('Enter the hours')
      end

      it 'is invalid if zero' do
        travel_time_expense.hours = 0
        expect(travel_time_expense).not_to be_valid
        expect(travel_time_expense.errors[:hours]).to include('Enter valid hours for the expense')
      end

      it 'is invalid if before earliest rep order date' do
        should_error_if_earlier_than_earliest_reporder_date(claim, expense, :date, 'Check the date for the expense')
      end

      it 'is invalid if more than two places of decimals' do
        travel_time_expense.hours = 6.789
        expect(travel_time_expense).not_to be_valid
        expect(travel_time_expense.errors[:hours]).to include('decimal')
      end

      it 'is valid if present and above zero with one place of decimals' do
        travel_time_expense.hours = 1.5
        expect(travel_time_expense).to be_valid
      end

      it 'is valid if present and above zero with two places of decimals' do
        travel_time_expense.hours = 1.52
        expect(travel_time_expense).to be_valid
      end

      it 'is valid if present and above zero with no decimals' do
        travel_time_expense.hours = 7
        expect(travel_time_expense).to be_valid
      end
    end

    context 'not travel time' do
      let(:expenses_to_test) do
        [car_travel_expense, bike_travel_expense, parking_expense, hotel_accommodation_expense, train_expense,
         road_tolls_expense, cab_fares_expense, subsistence_expense]
      end

      it 'is invalid if present' do
        expenses_to_test.each do |ex|
          ex.hours = 5
          expect(ex).not_to be_valid
          expect(ex.errors[:hours]).to include('Enter valid hours')
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
      it 'is valid if present' do
        other_reason_type_expense.reason_text = 'my reasons'
        expect(other_reason_type_expense).to be_valid
      end

      it 'is invalid if absent' do
        other_reason_type_expense.reason_text = nil
        expect(other_reason_type_expense).not_to be_valid
        expect(other_reason_type_expense.errors[:reason_text]).to include('Enter a reason')
      end
    end
  end

  describe '#validate_claim' do
    it { should_error_if_not_present(expense, :claim, 'blank') }
  end

  describe '#validate_expense_type' do
    it { should_error_if_not_present(expense, :expense_type, 'Choose an expense type') }
  end

  describe '#validate_location' do
    let(:expenses_to_test) do
      [car_travel_expense, bike_travel_expense, hotel_accommodation_expense, train_expense, road_tolls_expense,
       cab_fares_expense, subsistence_expense]
    end

    it 'is mandatory for everything except parking and travel time' do
      expenses_to_test.each do |ex|
        ex.location = nil
        expect(ex.valid?).to be false
        expect(ex.errors[:location]).to include('Enter a location')
      end
    end

    it 'is valid when a location specified for everything except parking and travel time' do
      expenses_to_test.each do |ex|
        ex.location = 'Somewhere'
        expect(ex).to be_valid
      end
    end

    it 'enforces absence for parking' do
      parking_expense.location = 'Somewhere'
      expect(parking_expense.valid?).to be false
      expect(parking_expense.errors[:location]).to include 'Enter a valid location'
    end

    it 'is valid when empty for parking' do
      parking_expense.location = nil
      expect(parking_expense).to be_valid
    end
  end

  describe 'location type validations' do
    context 'when the location type is not set' do
      subject(:expense) { build(:expense, :train, claim:, location_type: '') }

      it { is_expected.to be_valid }
    end

    context 'when the location type is set' do
      context 'but does not match a valid type' do
        subject(:expense) { build(:expense, :train, claim:, location_type: 'Enter a valid location') }

        it {
          is_expected.not_to be_valid
          expect(expense.errors[:location_type]).to include('Enter a valid location')
        }
      end
    end
  end

  describe '#validate_reason_id' do
    it 'is valid with values 1-4 for reason set A' do
      (1..4).each do |i|
        expense.expense_type.reason_set = 'A'
        expense.reason_id = i
        expense.reason_text = 'xxx' if expense.expense_reason_other?
        expect(expense).to be_valid
      end
    end

    it 'is valid with value 5 for reason set A with reason text filled' do
      expense.expense_type.reason_set = 'A'
      expense.reason_id = 5
      expense.reason_text = 'blah'
      expect(expense).to be_valid
    end

    it 'is invalid with value 5 for reason set A without reason text filled' do
      expense.expense_type.reason_set = 'A'
      expense.reason_id = 5
      expect(expense).not_to be_valid
      expect(expense.errors[:reason_text]).to include('Enter a reason')
    end

    it 'is invalid with values 6 and above for reason set A' do
      [0, 6, 22].each do |i|
        expense.expense_type.reason_set = 'B'
        expense.reason_id = i
        expect(expense.valid?).to be false
        expect(expense.errors[:reason_id]).to include('Enter a valid reason for the expense')
      end
    end

    it 'is valid with values 1-4 for reason set B' do
      (1..4).each do |i|
        expense.expense_type.reason_set = 'A'
        expense.reason_id = i
        expect(expense).to be_valid
      end
    end

    it 'is invalid with values 5 and above for reason set B' do
      [0, 5, 15].each do |i|
        expense.expense_type.reason_set = 'B'
        expense.reason_id = i
        expect(expense.valid?).to be false
        expect(expense.errors[:reason_id]).to include('Enter a valid reason for the expense')
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
        expect(expense.errors[:reason_text]).to include('Enter a reason')
      end
    end

    context 'validates absence when reason ID is other than 5 regardless of the reason set' do
      subject { expense.valid? }

      before do
        expense.reason_id = 3
      end

      context 'reason text is present' do
        before { expense.reason_text = 'blah' }

        it 'removes the reason text before validation' do
          expect(subject).to be true
          expect(expense.reason_text).to be_nil
        end
      end

      context 'reason text is not present' do
        it { is_expected.to be true }
      end
    end
  end

  describe '#validate_distance' do
    context 'valid' do
      it 'is valid when present for car travel' do
        car_travel_expense.distance = 33
        expect(car_travel_expense).to be_valid
      end

      it 'is valid when present for bike travel' do
        bike_travel_expense.distance = 33
        expect(bike_travel_expense).to be_valid
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
        expect(car_travel_expense.errors[:distance]).to include('Enter the distance for the expense')
      end
    end
  end

  describe '#validate_calculated_distance' do
    context 'when the expense is not car travel' do
      subject(:expense) { hotel_accommodation_expense }

      context 'and the calculated distance is not set' do
        before do
          expense.calculated_distance = nil
        end

        it 'is valid' do
          expect(expense).to be_valid
        end
      end

      context 'and the calculated distance is set' do
        before do
          expense.calculated_distance = 12345
        end

        it 'is valid' do
          expect(expense).to be_valid
        end
      end
    end

    context 'when the expense is car travel' do
      subject(:expense) { car_travel_expense }

      context 'and the calculated distance is not set' do
        before do
          expense.calculated_distance = nil
        end

        it 'is valid' do
          expect(expense).to be_valid
        end
      end

      context 'and the calculated distance is zero' do
        before do
          expense.calculated_distance = 0.0
        end

        it 'is valid' do
          expect(expense).to be_valid
        end
      end

      context 'and the calculated distance is set' do
        let(:calculated_distance) { 123456 }

        before do
          expense.calculated_distance = calculated_distance
        end

        it { expect(expense).to be_valid }

        context 'but has a value set below the minumum acceptable' do
          let(:calculated_distance) { -0.0001 }

          it 'is invalid' do
            expect(expense).not_to be_valid
            expect(expense.errors[:calculated_distance]).to include('Enter a valid distance for the expense')
          end
        end
      end
    end
  end

  describe '#distance' do
    context 'when the expense is not car or bike travel' do
      let(:expenses_to_test) do
        [parking_expense, travel_time_expense, hotel_accommodation_expense, train_expense, road_tolls_expense,
         cab_fares_expense, subsistence_expense]
      end

      it 'is invalid if present' do
        expenses_to_test.each do |ex|
          ex.distance = 2
          expect(ex).not_to be_valid
          expect(ex.errors[:distance]).to include('Enter a valid distance')
        end
      end

      it 'is valid when absent' do
        expenses_to_test.each do |ex|
          ex.distance = nil
          expect(ex).to be_valid
        end
      end
    end

    context 'when the expense is car travel' do
      it 'is valid when positive' do
        car_travel_expense.distance = 1
        expect(car_travel_expense).to be_valid
      end

      it 'is invalid when zero' do
        car_travel_expense.distance = 0
        expect(car_travel_expense).not_to be_valid
        expect(car_travel_expense.errors[:distance]).to include('Enter a valid distance for the expense')
      end

      it 'is invalid when negative' do
        car_travel_expense.distance = -5
        expect(car_travel_expense).not_to be_valid
        expect(car_travel_expense.errors[:distance]).to include('Enter a valid distance for the expense')
      end
    end

    context 'when the expense is bike travel' do
      it 'is valid when positive' do
        bike_travel_expense.distance = 1
        expect(bike_travel_expense).to be_valid
      end

      it 'is invalid when zero' do
        bike_travel_expense.distance = 0
        expect(bike_travel_expense).not_to be_valid
        expect(bike_travel_expense.errors[:distance]).to include('Enter a valid distance for the expense')
      end

      it 'is invalid when negative' do
        bike_travel_expense.distance = -5
        expect(bike_travel_expense).not_to be_valid
        expect(bike_travel_expense.errors[:distance]).to include('Enter a valid distance for the expense')
      end
    end
  end

  describe 'validate_mileage_rate_id' do
    context 'when the expense is not car or bike travel' do
      let(:expenses_to_test) do
        [parking_expense, travel_time_expense, hotel_accommodation_expense, train_expense, road_tolls_expense,
         cab_fares_expense, subsistence_expense]
      end

      it 'is invalid if present' do
        expenses_to_test.each do |ex|
          ex.mileage_rate_id = 2
          expect(ex).not_to be_valid
          expect(ex.errors[:mileage_rate_id]).to include('Select a valid mileage rate')
        end
      end

      it 'is valid when absent' do
        expenses_to_test.each do |ex|
          ex.mileage_rate_id = nil
          expect(ex).to be_valid
        end
      end
    end

    context 'when the expense is car travel' do
      it 'is invalid if not a value in the settings' do
        car_travel_expense.mileage_rate_id = 4
        expect(car_travel_expense).not_to be_valid
        expect(car_travel_expense.errors[:mileage_rate_id]).to include('Select a valid mileage rate')
      end

      it 'is invalid if bike travel rate' do
        car_travel_expense.mileage_rate_id = 3
        expect(car_travel_expense).not_to be_valid
        expect(car_travel_expense.errors[:mileage_rate_id]).to include('Select a valid mileage rate')
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
        expect(car_travel_expense.errors[:mileage_rate_id]).to include('Select a mileage rate')
      end
    end

    context 'when the expense is bike travel' do
      it 'is invalid if not a value in the settings' do
        bike_travel_expense.mileage_rate_id = 4
        expect(bike_travel_expense).not_to be_valid
        expect(bike_travel_expense.errors[:mileage_rate_id]).to include('Select a valid mileage rate')
      end

      it 'is invalid if car travel rate' do
        [1, 2].each do |i|
          bike_travel_expense.mileage_rate_id = i
          expect(bike_travel_expense).not_to be_valid
        end
      end

      context 'schema_version 1' do
        let(:claim)   { build(:claim, force_validation: true) }
        let(:expense) { build(:expense, claim:, expense_type: build(:expense_type)) }

        before { allow(Settings).to receive(:expense_schema_version).and_return(1) }

        it 'is invalid if absent' do
          bike_travel_expense.mileage_rate_id = nil
          expect(bike_travel_expense).not_to be_valid
          expect(bike_travel_expense.errors[:mileage_rate_id]).to include('Select a mileage rate')
        end
      end
    end
  end
end
