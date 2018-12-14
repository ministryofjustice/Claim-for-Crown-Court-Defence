require 'rails_helper'

RSpec.describe Claims::FetchEligibleMiscFeeTypes, type: :service do
  before(:all) do
    seed_fee_schemes
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

    # LGFS misc fees are those eligible for lgfs (via roles)
    # but excluding defendant uplifts since these are catered
    # for by fee calculation.
    context 'LGFS' do
      let(:claim) { create(:litigator_claim, :without_fees) }

      it { is_expected.to all(be_a(Fee::MiscFeeType)) }

      it 'returns LGFS only misc fee types' do
        expect(call.map(&:lgfs?)).to be_all true
      end

      context 'defendant uplift' do
        # TODO: keeping defendant uplifts for claims for fixed fees, awaiting BA feedback
        context 'fixed fee claim' do
          let(:claim) do
            create(:litigator_claim, :without_fees, case_type: CaseType.find_by(name: 'Appeal against sentence') )
          end

          it 'returns all LGFS misc fee types' do
            expect(call.map(&:unique_code)).to match_array %w[MICJA MICJP MIUPL MIEVI MISPF]
          end
        end

        context 'graduated fee claim' do
          let(:claim) do
            create(:litigator_claim, :without_fees, case_type: CaseType.find_by(name: 'Trial') )
          end

          it 'returns all LGFS misc fee types except defendant uplifts' do
            expect(call.map(&:unique_code)).to match_array %w[MICJA MICJP MIEVI MISPF]
          end
        end
      end
    end

    context 'AGFS' do
      let(:claim) { create(:advocate_claim) }

      it { is_expected.to all(be_a(Fee::MiscFeeType)) }

      context 'scheme 9 claim' do
        let(:claim) { create(:claim, :agfs_scheme_9) }

        it 'returns only misc fee types for AGFS scheme 9' do
          is_expected.to have_at_least(1).items
          is_expected.to match_array Fee::MiscFeeType.agfs_scheme_9s
        end
      end

      context 'scheme 10+ claim' do
        let(:claim) { create(:claim, :agfs_scheme_10) }

        it 'returns only misc fee types for AGFS scheme 10+' do
          is_expected.to have_at_least(1).items
          is_expected.to match_array Fee::MiscFeeType.agfs_scheme_10s
        end
      end
    end
  end
end
