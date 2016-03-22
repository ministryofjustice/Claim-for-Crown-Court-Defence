# == Schema Information
#
# Table name: expense_types
#
#  id         :integer          not null, primary key
#  name       :string
#  created_at :datetime
#  updated_at :datetime
#  roles      :string
#  reason_set :string
#

require 'rails_helper'

RSpec.describe ExpenseType, type: :model do
  it_behaves_like 'roles', ExpenseType, ExpenseType::ROLES

  it { should have_many(:expenses) }

  it { should validate_presence_of(:name) }
  it { should validate_uniqueness_of(:name) }

  context 'ROLES' do
    it 'should have "agfs" and "lgfs"' do
      expect(Provider::ROLES).to match_array(%w( agfs lgfs ))
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
        expect(expense_type_set_a.expense_reasons.map(&:id)).to eq( [ 1, 2, 3, 4, 5 ] )
      end

      it 'returns reason set b' do
        expect(expense_type_set_b.expense_reasons.map(&:id)).to eq( [ 1, 2, 3, 4 ] )
      end
    end

    describe '#expense_reason_by_id' do
      it 'returns the appropriate reason for set A' do
        expect(expense_type_set_a.expense_reason_by_id(5)).to eq ExpenseReason.new(5, 'Other', true)
      end

      it 'returns the appropriate reason for set B' do
        expect(expense_type_set_b.expense_reason_by_id(1)).to eq ExpenseReason.new(1, 'Court hearing', false)
      end

      it 'raises if invalid id given' do
        expect {
          expense_type_set_b.expense_reason_by_id(5)
        }.to raise_error ArgumentError, "No such ExpenseReason with id 5"
      end
    end
  end

  describe '.for_claim_type' do
    context 'for an advocate claim' do
      let(:claim) { Claim::AdvocateClaim.new }

      it 'returns applicable expense types for AGFS' do
        expect(described_class).to receive(:agfs)
        described_class.for_claim_type(claim)
      end
    end

    context 'for a litigator claim' do
      let(:claim) { Claim::LitigatorClaim.new }

      it 'returns applicable expense types for LGFS' do
        expect(described_class).to receive(:lgfs)
        described_class.for_claim_type(claim)
      end
    end
  end
end
