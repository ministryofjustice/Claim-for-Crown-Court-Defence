require 'rails_helper'

RSpec.describe Claims::FetchEligibleFixedFeeTypes, type: :service do
  before(:all) do
    seed_case_types
    seed_fee_types
  end

  after(:all) { clean_database }

  describe '#call' do
    subject(:call) { described_class.new(claim).call }

    context 'nil claim' do
      let(:claim) { nil }
      it { is_expected.to eq(nil) }
    end

    # TODO: LGFS eligible fee types currently returns all LGFS fixed fee type
    # but this is not be needed nor used by view logic because the only fixed fee
    # claimable on an LGFS fixed fee case type is the "matching" fee type. This service
    # is not used for LGFS claims.
    context 'LGFS' do
      let(:claim) do
        create(:litigator_claim, :without_fees, case_type: CaseType.find_by(name: 'Appeal against conviction'))
      end

      it 'returns LGFS only fixed fee types' do
        expect(call.map(&:lgfs?)).to be_all true
      end
    end

    context 'AGFS' do
      AGFS_FIXED_FEE_ELIGIBILITY = {
        FXACV: %w[FXACV FXNOC FXNDR FXSAF FXADJ],
        FXASE: %w[FXASE FXNOC FXNDR FXSAF FXADJ],
        FXCBR: %w[FXCBR FXNOC FXNDR FXSAF FXADJ],
        FXCSE: %w[FXCSE FXNOC FXNDR FXSAF FXADJ],
        FXCON: %w[FXCON FXSAF FXADJ],
        FXENP: %w[FXENP FXNOC FXNDR]
      }.with_indifferent_access.freeze

      AGFS_GRAD_FEE_ELIGIBILITY = %w[GRRAK GRCBR GRDIS GRGLT GRRTR GRTRL]

      context 'advocate final claim' do
        let(:claim) { create(:advocate_claim) }
        it { is_expected.to all(be_a(Fee::FixedFeeType)) }

        context 'fixed fee case types' do
          AGFS_FIXED_FEE_ELIGIBILITY.each do |fee_type_code, eligible_fee_type_unique_codes|
            context "case type #{fee_type_code}" do
              let(:case_type) { CaseType.find_by(fee_type_code: fee_type_code) }
              before { allow(claim).to receive(:case_type).and_return case_type }

              it "returns fee types with unique codes #{eligible_fee_type_unique_codes}" do
                expect(call.map(&:unique_code)).to match_array(eligible_fee_type_unique_codes)
              end
            end
          end
        end

        context 'graduated fee case types' do
          AGFS_GRAD_FEE_ELIGIBILITY.each do |fee_type_code|
            context "case type #{fee_type_code}" do
              let(:case_type) { CaseType.find_by(fee_type_code: fee_type_code) }
              before { allow(claim).to receive(:case_type).and_return case_type }

              it { is_expected.to be_empty }
            end
          end
        end
      end

      context 'advocate interim claim' do
        let(:claim) { create(:advocate_interim_claim, :agfs_scheme_10) }

        it { is_expected.to be_nil }
      end
    end
  end
end
