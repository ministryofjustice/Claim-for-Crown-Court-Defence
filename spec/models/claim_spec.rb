require 'rails_helper'

RSpec.describe Claim, type: :model do
  it { should belong_to(:advocate) }
  it { should belong_to(:court) }
  it { should belong_to(:offence) }
  it { should belong_to(:scheme) }
  it { should have_many(:fees) }
  it { should have_many(:fee_types) }
  it { should have_many(:expenses) }
  it { should have_many(:defendants) }
  it { should have_many(:documents) }
  it { should have_many(:messages) }

  it { should have_many(:case_worker_claims) }
  it { should have_many(:case_workers) }

  it { should validate_presence_of(:advocate) }
  it { should validate_presence_of(:court) }
  it { should validate_presence_of(:offence) }
  it { should validate_presence_of(:case_number) }
  it { should validate_presence_of(:prosecuting_authority) }
  it { should validate_inclusion_of(:prosecuting_authority).in_array(%w( cps )) }

  it { should validate_presence_of(:case_type) }
  it { should validate_inclusion_of(:case_type).in_array(%w( guilty trial retrial cracked_retrial )) }

  it { should validate_presence_of(:advocate_category) }
  it { should validate_inclusion_of(:advocate_category).in_array(%w( qc_alone led_junior leading_junior junior_alone )) }

  it { should validate_numericality_of(:estimated_trial_length).is_greater_than_or_equal_to(0) }
  it { should validate_numericality_of(:actual_trial_length).is_greater_than_or_equal_to(0) }

  it { should accept_nested_attributes_for(:fees) }
  it { should accept_nested_attributes_for(:expenses) }
  it { should accept_nested_attributes_for(:defendants) }
  it { should accept_nested_attributes_for(:documents) }

  subject { create(:claim) }

  describe '.find_by_maat_reference' do
    let!(:other_claim) { create(:claim) }

    before do
      create(:defendant, maat_reference: '111111', claim_id: subject.id)
      create(:defendant, maat_reference: '222222', claim_id: subject.id)
      create(:defendant, maat_reference: '333333', claim_id: other_claim.id)
      subject.reload
      other_claim.reload
    end

    it 'finds the claim by MAAT reference "111111"' do
      expect(Claim.find_by_maat_reference('111111')).to eq([subject])
    end

    it 'finds the claim by MAAT reference "222222"' do
      expect(Claim.find_by_maat_reference('222222')).to eq([subject])
    end

    it 'finds the claim by MAAT reference "333333"' do
      expect(Claim.find_by_maat_reference('333333')).to eq([other_claim])
    end

    it 'does not find a claim with MAAT reference "444444"' do
      expect(Claim.find_by_maat_reference('444444')).to be_empty
    end
  end

  describe '.find_by_advocate_name' do
    let!(:other_claim) { create(:claim) }

    before do
      subject.advocate = create(:advocate)
      other_claim.advocate = create(:advocate)
      subject.advocate.user.first_name = 'John'
      subject.advocate.user.last_name = 'Smith'
      subject.advocate.user.save!

      subject.save!

      other_claim.advocate.user.first_name = 'Bob'
      other_claim.advocate.user.last_name = 'Hoskins'
      other_claim.advocate.user.save!

      other_claim.save!
    end

    it 'finds the claim by advocate name "John Smith"' do
      expect(Claim.find_by_advocate_name('John Smith')).to eq([subject])
    end

    it 'finds the claim by advocate name "Bob Hoskins"' do
      expect(Claim.find_by_advocate_name('Bob Hoskins')).to eq([other_claim])
    end

    it 'does not find a claim with advocate name "Foo Bar"' do
      expect(Claim.find_by_advocate_name('Foo Bar')).to be_empty
    end
  end

  context 'fees total' do
    let(:fee_type) { create(:fee_type) }

    before do
      create(:fee, fee_type: fee_type, claim_id: subject.id, amount: 5.0)
      create(:fee, fee_type: fee_type, claim_id: subject.id, amount: 2.0)
      create(:fee, fee_type: fee_type, claim_id: subject.id, amount: 1.0)
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
        create(:fee, fee_type: fee_type, claim_id: subject.id, amount: 2.0)
        subject.reload
        expect(subject.fees_total).to eq(10.0)
      end

      it 'updates total when claim fee destroyed' do
        fee = subject.fees.first
        fee.destroy
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
    let(:fee_type) { create(:fee_type) }

    before do
      create(:fee, fee_type: fee_type, claim_id: subject.id, amount: 5.0)
      create(:fee, fee_type: fee_type, claim_id: subject.id, amount: 2.0)
      create(:fee, fee_type: fee_type, claim_id: subject.id, amount: 1.0)

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
        create(:fee, fee_type: fee_type, claim_id: subject.id, amount: 1.0)
        subject.reload
        expect(subject.total).to eq(158.5)
      end

      it 'updates total when expense/fee destroyed' do
        expense = subject.expenses.first
        fee = subject.fees.first
        expense.destroy
        fee.destroy
        subject.reload
        expect(subject.total).to eq(146.0)
      end
    end
  end

  describe '#description' do
    let(:expected_output) do
      "#{subject.court.code}-#{subject.case_number} #{subject.advocate.name} (#{subject.advocate.chamber.name})"
    end

    it 'returns a formatted description string containing claim information' do
      expect(subject.description).to eq(expected_output)
    end
  end

  describe '#editable?' do
    let(:draft) { create(:claim) }
    let(:submitted) { create(:submitted_claim) }
    let(:allocated) { create(:allocated_claim) }

    it 'should be editable when draft' do
      expect(draft.editable?).to eq(true)
    end

    it 'should be editable when submitted' do
      expect(submitted.editable?).to eq(true)
    end

    it 'should not be editable when allocated' do
      expect(allocated.editable?).to eq(false)
    end
  end
end
