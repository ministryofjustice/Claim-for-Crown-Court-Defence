require 'rails_helper'
require 'services/cleaners/cleaner_shared_examples'

RSpec.describe Cleaners::LitigatorClaimCleaner do
  subject(:cleaner) { described_class.new(claim) }

  describe '#call' do
    subject(:call_cleaner) { cleaner.call }

    context 'when changing a graduated fee claim to a fixed fee claim' do
      let(:claim) do
        create(
          :litigator_claim,
          case_type: build(:case_type, :graduated_fee),
          graduated_fee: build(:graduated_fee)
        )
      end

      before do
        claim.case_type = build(:case_type, :fixed_fee)
        claim.fixed_fee = build(:fixed_fee, :fxase_fee, :with_date_attended, rate: 9.99)
      end

      it 'keeps the fixed fee and clears the graduated fee when switching to a fixed fee claim' do
        call_cleaner

        aggregate_failures do
          expect(claim.fixed_fee).to be_a(Fee::FixedFee)
          expect(claim.graduated_fee).to be_nil
        end
      end
    end

    context 'when changing a fixed fee claim to a graduated fee claim' do
      let(:claim) do
        create(
          :litigator_claim,
          case_type: build(:case_type, :fixed_fee),
          fixed_fee: build(:fixed_fee, :fxase_fee, :with_date_attended, rate: 9.99)
        )
      end

      before do
        claim.case_type = build(:case_type, :graduated_fee)
        claim.graduated_fee = build(:graduated_fee)
      end

      it 'clears the fixed fee and keeps the graduated fee when switching to a graduated fee claim' do
        call_cleaner

        aggregate_failures do
          expect(claim.fixed_fee).to be_nil
          expect(claim.graduated_fee).to be_a(Fee::GraduatedFee)
        end
      end
    end
  end
end
