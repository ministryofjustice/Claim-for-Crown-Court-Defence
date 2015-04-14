require 'rails_helper'

RSpec.describe Claim, type: :model do
  it { should belong_to(:advocate) }
  it { should belong_to(:court) }
  it { should have_many(:claim_fees) }
  it { should have_many(:fees) }
  it { should have_many(:expenses) }
  it { should have_many(:defendants) }
  it { should have_many(:documents) }

  it { should have_many(:case_worker_claims) }
  it { should have_many(:case_workers) }

  it { should validate_presence_of(:advocate) }
  it { should validate_presence_of(:court) }
  it { should validate_presence_of(:case_number) }

  it { should validate_presence_of(:case_type) }
  it { should validate_inclusion_of(:case_type).in_array(%w( guilty trial retrial cracked_retrial )) }

  it { should validate_presence_of(:offence_class) }
  it { should validate_inclusion_of(:offence_class).in_array(('A'..'J').to_a) }

  it { should accept_nested_attributes_for(:claim_fees) }
  it { should accept_nested_attributes_for(:expenses) }
  it { should accept_nested_attributes_for(:defendants) }

  subject { create(:claim) }

  context 'fees total' do
    let(:fee) { create(:fee) }

    before do
      create(:claim_fee, fee_id: fee, claim_id: subject.id, amount: 5.0)
      create(:claim_fee, fee_id: fee, claim_id: subject.id, amount: 2.0)
      create(:claim_fee, fee_id: fee, claim_id: subject.id, amount: 1.0)
      subject.reload
    end

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
        create(:claim_fee, fee_id: fee, claim_id: subject.id, amount: 2.0)
        subject.reload
        expect(subject.fees_total).to eq(10.0)
      end

      it 'updates total when claim fee destroyed' do
        claim_fee = subject.claim_fees.first
        claim_fee.destroy
        subject.reload
        expect(subject.fees_total).to eq(3.0)
      end
    end
  end

  context 'expenses total' do
    before do
      create(:expense, claim_id: subject.id, amount: 3.5)
      create(:expense, claim_id: subject.id, amount: 1.0)
      create(:expense, claim_id: subject.id, amount: 142.0)
      subject.reload
    end

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
        create(:expense, claim_id: subject.id, amount: 3.0)
        subject.reload
        expect(subject.expenses_total).to eq(149.5)
      end

      it 'updates expenses total when expense destroyed' do
        expense = subject.expenses.first
        expense.destroy
        subject.reload
        expect(subject.expenses_total).to eq(143.0)
      end
    end
  end

  context 'total' do
    let(:fee) { create(:fee) }

    before do
      create(:claim_fee, fee_id: fee, claim_id: subject.id, amount: 5.0)
      create(:claim_fee, fee_id: fee, claim_id: subject.id, amount: 2.0)
      create(:claim_fee, fee_id: fee, claim_id: subject.id, amount: 1.0)

      create(:expense, claim_id: subject.id, amount: 3.5)
      create(:expense, claim_id: subject.id, amount: 1.0)
      create(:expense, claim_id: subject.id, amount: 142.0)
      subject.reload
    end

    describe '#calculate_total' do
      it 'calculates the fees and expenses total' do
        expect(subject.calculate_total).to eq(154.5)
      end
    end

    describe '#update_total' do
      it 'updates the total' do
        create(:expense, claim_id: subject.id, amount: 3.0)
        create(:claim_fee, fee_id: fee, claim_id: subject.id, amount: 1.0)
        subject.reload
        expect(subject.total).to eq(158.5)
      end

      it 'updates total when expense/fee destroyed' do
        expense = subject.expenses.first
        claim_fee = subject.claim_fees.first
        expense.destroy
        claim_fee.destroy
        subject.reload
        expect(subject.total).to eq(146.0)
      end
    end
  end
end
