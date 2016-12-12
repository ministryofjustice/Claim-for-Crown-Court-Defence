require 'rails_helper'

RSpec.describe Claim, type: :model do
  subject { create(:claim) }
  let(:expenses) { [3.5, 1.0, 142.0].each { |amount| create(:expense, claim_id: subject.id, amount: amount) } }
  let(:fee_type) { create(:fixed_fee_type) }

  context 'fees total' do

    describe '#calculate_fees_total' do
      it 'calculates the fees total' do
        expect(subject.calculate_fees_total).to eq(25.0)
      end
    end

    describe '#update_fees_total' do
      it 'stores the fees total' do
        expect(subject.fees_total).to eq(25.0)
      end

      it 'updates the fees total' do
        create(:fixed_fee, fee_type: fee_type, claim_id: subject.id, rate: 2.00)
        subject.reload
        expect(subject.fees_total).to eq(27.0)
      end

      it 'updates total when claim fee destroyed' do
        create(:fixed_fee, fee_type: fee_type, claim_id: subject.id, rate: 2.00)
        subject.fees.first.destroy
        subject.reload
        expect(subject.fees_total).to eq(2.0)
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
        create(:expense, claim_id: subject.id, amount: 3)
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

  context 'expenses vat' do
    let!(:expenses) { [3.5, 1.0, 142.0].each { |amount| create(:expense, claim_id: subject.id, amount: amount, vat_amount: 2) } }

    before { subject.reload }

    context 'AGFS claim' do
      subject { create(:claim) }

      it 'calculates the claim expenses VAT' do
        # rate 17.5, see rails_helper
        expect(subject.calculate_expenses_vat).to eq(25.64)
      end
    end

    context 'LGFS claim' do
      subject { create(:litigator_claim, apply_vat: true) }
      let!(:expenses) { [3.5, 1.0, 142.0].each { |amount| create(:expense, claim_id: subject.id, amount: amount, vat_amount: 2) } }

      it 'calculates the claim expenses VAT' do
        expect(subject.calculate_expenses_vat).to eq(6.0)
      end
    end
  end

  context 'total' do
    before { expenses; subject.reload }

    describe '#calculate_total' do
      # TODO reinstate once fees, expenses and disbursement vat has been dealt with
      it 'calculates the fees and expenses total' do
        create(:expense, claim_id: subject.id, amount: 3.0)
        ap subject.expenses.map(&:amount)
        ap subject.fees.map(&:amount)
        expect(subject.calculate_total).to eq(174.5)
      end
    end

    describe '#update_total' do
      it 'updates the total' do
        create(:expense, claim_id: subject.id, amount: 3)
        create(:fixed_fee, fee_type: fee_type, claim_id: subject.id, rate: 4.00)
        subject.reload
        expect(subject.total).to eq(178.5)
      end

      it 'updates total when expense/fee destroyed' do
        subject.expenses.first.destroy # 3.5
        subject.fees.first.destroy # 250.0
        subject.reload
        expect(subject.total).to eq(143.00)
      end
    end
  end
end
