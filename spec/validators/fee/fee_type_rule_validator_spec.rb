require 'rails_helper'

RSpec.describe Fee::FeeTypeRuleValidator, type: :validator do
  describe '#validate' do
    subject(:validate) { described_class.new(fee, fee_type_rules).validate }

    before do
      create(:misc_fee_type, :miumu)
      create(:misc_fee_type, :miumo)
    end

    let(:fee_type_rules) { Fee::FeeTypeRules.where(unique_code: fee.fee_type.unique_code) }

    context 'when fee quantity must equal x' do
      context 'with a valid fee' do
        let(:fee) { build(:misc_fee, :miumu_fee, quantity: 1) }

        it { is_expected.to be_truthy }

        it 'does not add error to fee' do
          expect{ validate }.not_to change(fee.errors[:quantity], :count)
        end
      end

      context 'with an invalid fee' do
        let(:fee) { build(:misc_fee, :miumu_fee, quantity: 1.01) }

        it { is_expected.to be_falsey }

        it 'adds an active record error' do
          expect { validate }.to change(fee.errors[:quantity], :count).by 1
        end

        it 'adds an active record error message' do
          validate
          expect(fee.errors[:quantity]).to match_array(['miumu_numericality'])
        end
      end
    end

    context 'when fee quantity has a minimum' do
      context 'with a valid fee' do
        let(:fee) { build(:misc_fee, :miumo_fee, quantity: 3.0) }

        it { is_expected.to be_truthy }

        it 'does not add error to fee' do
          expect{ validate }.not_to change(fee.errors[:quantity], :count)
        end
      end

      context 'with an invalid fee' do
        let(:fee) { build(:misc_fee, :miumo_fee, quantity: 2.99) }

        it { is_expected.to be_falsey }

        it 'adds an active record error' do
          expect { validate }.to change(fee.errors[:quantity], :count).by 1
        end

        it 'adds an active record error message' do
          validate
          expect(fee.errors[:quantity]).to match_array(['miumo_numericality'])
        end
      end
    end
  end
end
