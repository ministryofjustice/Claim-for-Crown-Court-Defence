# == Schema Information
#
# Table name: expense_types
#
#  id          :integer          not null, primary key
#  name        :string
#  created_at  :datetime
#  updated_at  :datetime
#  roles       :string
#  reason_set  :string
#  unique_code :string
#

require 'rails_helper'

RSpec.describe ExpenseType, type: :model do
  it_behaves_like 'roles', ExpenseType, ExpenseType::ROLES

  it { should have_many(:expenses) }

  it { should validate_presence_of(:name) }
  it { should validate_uniqueness_of(:name).ignoring_case_sensitivity.with_message('An expense type with this name already exists') }

  context 'ROLES' do
    it 'should have "agfs" and "lgfs"' do
      expect(Provider::ROLES).to match_array(%w(agfs lgfs))
    end
  end

  context 'expense types helper methods' do
    let(:car_travel_expense)          { build(:expense_type, :car_travel) }
    let(:bike_travel_expense)         { build(:expense_type, :bike_travel) }
    let(:parking_expense)             { build(:expense_type, :parking) }
    let(:hotel_accommodation_expense) { build(:expense_type, :hotel_accommodation) }
    let(:train_expense)               { build(:expense_type, :train) }
    let(:travel_time_expense)         { build(:expense_type, :travel_time) }
    let(:road_tolls_expense)          { build(:expense_type, :road_tolls) }
    let(:cab_fares_expense)           { build(:expense_type, :cab_fares) }
    let(:subsistence_expense)         { build(:expense_type, :subsistence) }

    it 'returns true for the type of expense it is' do
      expect(car_travel_expense.car_travel?).to be true
      expect(car_travel_expense.train?).to be false

      expect(bike_travel_expense.bike_travel?).to be true
      expect(bike_travel_expense.car_travel?).to be false

      expect(parking_expense.parking?).to be true
      expect(parking_expense.car_travel?).to be false

      expect(hotel_accommodation_expense.hotel_accommodation?).to be true
      expect(hotel_accommodation_expense.parking?).to be false

      expect(train_expense.train?).to be true
      expect(train_expense.hotel_accommodation?).to be false

      expect(travel_time_expense.travel_time?).to be true
      expect(travel_time_expense.train?).to be false

      expect(road_tolls_expense.road_tolls?).to be true
      expect(road_tolls_expense.car_travel?).to be false

      expect(cab_fares_expense.cab_fares?).to be true
      expect(cab_fares_expense.train?).to be false

      expect(subsistence_expense.subsistence?).to be true
      expect(subsistence_expense.hotel_accommodation?).to be false
    end
  end

  context 'expense reasons' do
    let(:expense_type_set_a) { create :expense_type }
    let(:expense_type_set_b) { create :expense_type, :reason_set_b }

    describe '#expense_reasons_hash' do
      it 'returns reason set a hash' do
        expect(expense_type_set_a.expense_reasons_hash).to eq ExpenseType::REASON_SET_A
      end

      it 'retuens reason set a hash' do
        expect(expense_type_set_b.expense_reasons_hash).to eq ExpenseType::REASON_SET_B
      end
    end

    describe '#expense_reasons' do
      it 'returns reason set a' do
        expect(expense_type_set_a.expense_reasons.map(&:id)).to eq([1, 2, 3, 4, 5])
      end

      it 'returns reason set b' do
        expect(expense_type_set_b.expense_reasons.map(&:id)).to eq([2, 3, 4])
      end
    end

    describe '#expense_reason_by_id' do
      it 'returns the appropriate reason for set A' do
        expect(expense_type_set_a.expense_reason_by_id(5)).to eq ExpenseReason.new(5, 'Other', true)
      end

      it 'returns the appropriate reason for set B' do
        expect(expense_type_set_b.expense_reason_by_id(2)).to eq ExpenseReason.new(2, 'Pre-trial conference expert witnesses', false)
      end

      it 'raises if invalid id given' do
        expect(expense_type_set_b.expense_reason_by_id(5)).to be_nil
      end
    end
  end

  describe '.for_claim_type' do
    context 'for an advocate claim' do
      let(:claim) { Claim::AdvocateClaim.new }

      it 'returns applicable expense types for AGFS' do
        expect(described_class).to receive(:agfs).and_return(double(order: []))
        described_class.for_claim_type(claim)
      end
    end

    context 'for a litigator claim' do
      let(:claim) { Claim::LitigatorClaim.new }

      it 'returns applicable expense types for LGFS' do
        expect(described_class).to receive(:lgfs).and_return(double(order: []))
        described_class.for_claim_type(claim)
      end
    end
  end
end
