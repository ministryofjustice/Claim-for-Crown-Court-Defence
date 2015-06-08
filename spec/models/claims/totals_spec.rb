require 'rails_helper'

RSpec.describe Claim, type: :model do
  subject { create(:claim) }
  let(:fees)     { [5.0, 2.0, 1.0].each { |rate| create(:fee, fee_type: fee_type, claim_id: subject.id, quantity: 1, rate: rate) } }
  let(:expenses) { [3.5, 1.0, 142.0].each { |rate| create(:expense, claim_id: subject.id, quantity: 1, rate: rate) } }

  context 'fees total' do
    let(:fee_type) { create(:fee_type) }
    before { fees; subject.reload }

    describe '#calculate_fees_total' do
      it 'calculates the fees total' do
        expect(subject.calculate_fees_total).to eq(8.0)
      end
    end

    describe '#update_fees_total' do
      it 'stores the fees total' do
        expect(subject.fees_total).to eq(8.0)
      end

      it 'updates the fees total' do
        create(:fee, fee_type: fee_type, claim_id: subject.id, quantity: 1, rate: 2.0)
        subject.reload
        expect(subject.fees_total).to eq(10.0)
      end

      it 'updates total when claim fee destroyed' do
        subject.fees.first.destroy
        subject.reload
        expect(subject.fees_total).to eq(3.0)
      end
    end
  end

  context 'expenses total' do
    before { expenses; subject.reload }

    describe '#calculate_expenses_total' do
      it 'calculates expenses total' do
        expect(subject.calculate_expenses_total).to eq(146.5)
      end
    end

    describe '#update_expenses_total' do
      it 'stores the expenses total' do
        expect(subject.expenses_total).to eq(146.5)
      end

      it 'updates the expenses total' do
        create(:expense, claim_id: subject.id, quantity: 3, rate: 1)
        subject.reload
        expect(subject.expenses_total).to eq(149.5)
      end

      it 'updates expenses total when expense destroyed' do
        subject.expenses.first.destroy
        subject.reload
        expect(subject.expenses_total).to eq(143.0)
      end
    end
  end

  context 'total' do
    let(:fee_type) { create(:fee_type) }

    before { fees; expenses; subject.reload }

    describe '#calculate_total' do
      it 'calculates the fees and expenses total' do
        expect(subject.calculate_total).to eq(154.5)
      end
    end

    describe '#update_total' do
      it 'updates the total' do
        create(:expense, claim_id: subject.id, quantity: 3, rate: 1)
        create(:fee, fee_type: fee_type, claim_id: subject.id, quantity: 1, rate: 1)
        subject.reload
        expect(subject.total).to eq(158.5)
      end

      it 'updates total when expense/fee destroyed' do
        subject.expenses.first.destroy
        subject.fees.first.destroy
        subject.reload
        expect(subject.total).to eq(146.0)
      end
    end
  end
end
