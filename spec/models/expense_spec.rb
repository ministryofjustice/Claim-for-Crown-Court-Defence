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
#  distance        :decimal(, )
#  mileage_rate_id :integer
#  date            :date
#  hours           :decimal(, )
#  vat_amount      :decimal(, )      default(0.0)
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

    [:car_travel?, :bike_travel?, :parking?, :hotel_accommodation?, :train?, :travel_time?, :road_tolls?, :cab_fares?, :subsistence?].each do |method|
      it "delegates #{method} to expense_type" do
        expect(expense_type).to receive(method)
        subject.send(method)
      end
    end
  end

  context 'zeroising nulls on save' do
    it 'zerosise nulls on save' do
      expense = create :expense, amount: nil, vat_amount: nil
      expect(expense.amount).to eq 0.0
      expect(expense.vat_amount).to eq 0.0
    end

    it 'does not zeroise the amount if not null' do
      expense = create :expense, amount: 100.0, vat_amount: nil
      expect(expense.amount).to eq 100.0
      expect(expense.vat_amount).to eq 20.0
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
        expect(ex_5.displayable_reason_text).to eq 'My unique reason'
      end
    end
  end

  describe 'comma formatted inputs' do
    [:rate, :quantity, :amount, :vat_amount].each do |attribute|
      it "converts input for #{attribute} by stripping commas out" do
        expense = build(:expense)
        expense.send("#{attribute}=", '12,321,111')
        expect(expense.send(attribute)).to eq(12321111)
      end
    end
  end

  describe '#distance_gt_calculated?' do
    subject { expense.distance_gt_calculated? }

    let(:attrs) {
      {
        distance: distance,
        calculated_distance: calculated_distance
      }
    }
    let(:expense) { described_class.new(attrs) }

    context 'when distance is not set' do
      let(:distance) { nil }
      let(:calculated_distance) { 234 }

      it { is_expected.to be_falsey }
    end

    context 'when calculated distance is not set' do
      let(:distance) { 234 }
      let(:calculated_distance) { nil }

      it { is_expected.to be_falsey }
    end

    context 'when both distance and calculated distance are set' do
      context 'and "claimed" distance is greater than "calculated"' do
        let(:distance) { 235 }
        let(:calculated_distance) { 234 }

        it { is_expected.to be_truthy }
      end

      context 'and they both have the same value' do
        let(:distance) { 234 }
        let(:calculated_distance) { 234 }

        it { is_expected.to be_falsey }
      end

      context 'and "claimed" distance is less than "calculated"' do
        let(:distance) { 233 }
        let(:calculated_distance) { 234 }

        it { is_expected.to be_falsey }
      end
    end
  end

  describe 'establishment' do
    subject { expense.establishment }

    context 'when the expense is car travel' do
      let(:expense) do
        build(:expense, :car_travel, calculated_distance: calculated_distance, location: location, date: 3.days.ago)
      end

      context 'when the expense has calculated_distance' do
        let(:distance) { 235 }
        let(:calculated_distance) { 235 }
        let(:establishment) { create(:establishment, :prison) }
        let(:location) { establishment.name }

        it { is_expected.to eql establishment }
      end

      context 'when the expense does not have calculated_distance' do
        let(:distance) { 235 }
        let(:calculated_distance) { nil }
        let(:location) { 'HMP test prison' }

        it { is_expected.to be nil }
      end
    end

    context 'when the expense is not car travel' do
      let(:expense) { build(:expense, :parking, date: 3.days.ago) }

      it { is_expected.to be nil }
    end
  end

  describe '#remove_reason_text_unless_other' do
    subject(:remove_reason_text_unless_other) { expense.remove_reason_text_unless_other }

    let(:expense) { build :expense, reason_id: 4, reason_text: 'My unique reason' }

    it { expect { remove_reason_text_unless_other }.to change { expense.reason_text }.to nil }
  end
end
