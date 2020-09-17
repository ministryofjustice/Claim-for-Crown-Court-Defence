require 'rails_helper'
require "rspec/mocks/standalone" # required for mocking/unmocking in before/after(:all) block

RSpec.shared_examples 'fetches AGFS fee scheme misc fee types excluding supplementary-only' do |claim_factory|
  subject(:unique_codes) { call.map(&:unique_code) }

  context 'scheme 9 claim' do
    let(:claim) { create(claim_factory, :agfs_scheme_9) }

    it 'returns only misc fee types for AGFS scheme 9 without supplementary-only fee types' do
      is_expected.to have_at_least(1).items
      is_expected.to match_array Fee::MiscFeeType.agfs_scheme_9s.without_supplementary_only.map(&:unique_code).reject
    end
  end

  context 'scheme 10+ claim' do
    let(:claim) { create(claim_factory, :agfs_scheme_10) }

    it 'returns only misc fee types for AGFS scheme 10+ without supplementary-only fee types' do
      is_expected.to have_at_least(1).items
      is_expected.to match_array Fee::MiscFeeType.agfs_scheme_10s.without_supplementary_only.map(&:unique_code)
    end
  end

  context 'scheme 12 claim' do
    let(:claim) { create(claim_factory, :agfs_scheme_12) }

    it 'returns misc fee types for AGFS scheme 10+ plus 12 without supplementary-only fee types' do
      is_expected.to have_at_least(1).items
      is_expected.to match_array Fee::MiscFeeType.agfs_scheme_12s.without_supplementary_only.map(&:unique_code)
    end
  end
end

RSpec.shared_context 'pre CLAR rep order date' do
  let(:pre_clar_date) { Settings.clar_release_date.end_of_day - 1.day }

  before do
    allow(claim)
      .to receive(:earliest_representation_order_date)
      .and_return(pre_clar_date)
  end
end

RSpec.shared_context 'post CLAR rep order date' do
  let(:post_clar_date) { Settings.clar_release_date.beginning_of_day }

  before do
    allow(claim)
      .to receive(:earliest_representation_order_date)
      .and_return(post_clar_date)
  end
end

RSpec.describe Claims::FetchEligibleMiscFeeTypes, type: :service do
  before(:all) do |example|
    allow(Settings).to receive(:clar_enabled?).and_return true
    seed_fee_schemes
    seed_case_types
    seed_fee_types
  end

  after(:all) do
    clean_database
    allow(Settings).to receive(:clar_enabled?).and_call_original
  end

  context 'with delegations' do
    subject { described_class.new(nil) }

    it { is_expected.to delegate_method(:case_type).to(:claim).allow_nil }
    it { is_expected.to delegate_method(:agfs?).to(:claim).allow_nil }
    it { is_expected.to delegate_method(:lgfs?).to(:claim).allow_nil }
    it { is_expected.to delegate_method(:agfs_reform?).to(:claim).allow_nil }
    it { is_expected.to delegate_method(:agfs_scheme_12?).to(:claim).allow_nil }
    it { is_expected.to delegate_method(:hardship?).to(:claim).allow_nil }
  end

  describe '#call' do
    subject(:call) { described_class.new(claim).call }

    context 'with nil claim' do
      let(:claim) { nil }
      it { is_expected.to eq(nil) }
    end

    context 'with LGFS claim' do
      subject(:unique_codes) { call.map(&:unique_code) }

      context 'with final claim' do
        let(:claim) { create(:litigator_claim, :without_fees, case_type: case_type) }

        context 'with any case type' do
          let(:case_type) { create(:case_type) }

          it { expect(call).to all(be_a(Fee::MiscFeeType)) }

          it 'returns LGFS only misc fee types' do
            expect(call.map(&:lgfs?)).to be_all true
          end
        end

        context 'with fixed fee case type claim' do
          context 'when appeal against sentence' do
            let(:case_type) { CaseType.find_by(fee_type_code: 'FXASE') }

            it { is_expected.to include('MIUPL') }
            it { is_expected.to match_array %w[MICJA MICJP MIUPL MIEVI MISPF] }
          end
        end

        context 'with graduated case type fee claim' do
          context 'with any non-fixed-fee case type' do
            let(:case_type) { create(:case_type, is_fixed_fee: false) }

            it { is_expected.not_to include('MIUPL') }
          end

          context 'with "trial" fee claim' do
            let(:case_type) { CaseType.find_by(fee_type_code: 'GRTRL') }

            context 'with rep order pre CLAR' do
              include_context 'pre CLAR rep order date'

              it { is_expected.to match_array %w[MICJA MICJP MIEVI MISPF] }
            end

            context 'with rep order post CLAR' do
              include_context 'post CLAR rep order date'

              it { is_expected.to match_array %w[MICJA MICJP MIEVI MISPF MIUMU MIUMO] }
            end
          end

          context 'with "non-trial" fee claim' do
            include_context 'post CLAR rep order date'

            context 'when case type is Guilty plea' do
              let(:case_type) { CaseType.find_by(fee_type_code: 'GRGLT') }

              it { is_expected.to match_array %w[MICJA MICJP MIEVI MISPF] }
            end
          end
        end
      end

      context 'with hardship fee claim' do
        let(:claim) { create(:litigator_hardship_claim, case_stage: case_stage) }

        context 'when rep order is post CLAR' do
          include_context 'post CLAR rep order date'

          context 'with "trial" case stage' do
            let(:case_stage) { create(:case_stage, :trial_not_sentenced) }

            it 'returns only non-cost-judge LGFS misc fee types' do
              is_expected.to match_array %w[MIEVI MISPF MIUMU MIUMO]
            end
          end

          context 'with "non-trial" case stage' do
            let(:case_stage) { create(:case_stage, :guilty_plea_not_sentenced) }

            it 'returns only non-cost-judge, non-trial LGFS misc fee types' do
              is_expected.to match_array %w[MIEVI MISPF]
            end
          end
        end

        context 'when rep order is pre CLAR' do
          include_context 'pre CLAR rep order date'

          context 'with "trial" case stage' do
            let(:case_stage) { create(:case_stage, :trial_not_sentenced) }

            it 'returns only non-cost-judge, non-CLAR LGFS misc fee types' do
              is_expected.to match_array %w[MIEVI MISPF]
            end
          end

          context 'with "non-trial" case stage' do
            let(:case_stage) { create(:case_stage, :guilty_plea_not_sentenced) }

            it 'returns only non-cost-judge, non-trial LGFS misc fee types' do
              is_expected.to match_array %w[MIEVI MISPF]
            end
          end
        end
      end

      context 'with transfer fee claim' do
        let(:claim) { create(:litigator_transfer_claim, case_type: nil) }

        context 'with rep order pre CLAR' do
          include_context 'pre CLAR rep order date'

          it 'returns all LGFS misc fee types except defendant uplifts' do
            is_expected.to match_array %w[MICJA MICJP MIEVI MISPF]
          end
        end

        context 'with rep order post CLAR' do
          include_context 'post CLAR rep order date'

          it 'returns all LGFS misc fee types except defendant uplifts' do
            is_expected.to match_array %w[MICJA MICJP MIEVI MISPF MIUMU MIUMO]
          end
        end
      end
    end

    context 'with AGFS claim' do
      let(:claim) { create(:advocate_claim) }

      it { is_expected.to all(be_a(Fee::MiscFeeType)) }

      context 'with final claim' do
        include_examples 'fetches AGFS fee scheme misc fee types excluding supplementary-only', :advocate_claim
      end

      context 'with hardship claim' do
        include_examples 'fetches AGFS fee scheme misc fee types excluding supplementary-only', :advocate_hardship_claim
      end

      context 'with supplementary claim' do
        subject(:call) { described_class.new(claim).call.map(&:unique_code) }

        context 'when scheme 9 claim' do
          let(:claim) { create(:advocate_supplementary_claim, :agfs_scheme_9, with_misc_fee: false) }

          it 'returns only misc fee types for AGFS scheme 9 supplementary claims' do
            is_expected.to match_array %w[MISAF MISAU MIPCM MISPF MIWPF MIDTH MIDTW MIDHU MIDWU MIDSE MIDSU]
          end
        end

        context 'when scheme 10+ claim' do
          let(:claim) { create(:advocate_supplementary_claim, :agfs_scheme_10, with_misc_fee: false) }

          it 'returns only misc fee types for AGFS scheme 10+ supplementary claims' do
            is_expected.to match_array %w[MISAF MISAU MIPCM MISPF MIWPF MIDTH MIDTW MIDHU MIDWU MIDSE MIDSU]
          end
        end

        context 'when scheme 12 claim' do
          let(:claim) { create(:advocate_supplementary_claim, :agfs_scheme_12, with_misc_fee: false) }

          it 'returns misc fee types for AGFS scheme 10+ plus 12 with supplementary-only fee types' do
            is_expected.to match_array %w[MISAF MISAU MIPCM MISPF MIWPF MIDTH MIDTW MIDHU MIDWU MIDSE MIDSU MIPHC MIUMU MIUMO]
          end
        end
      end
    end
  end
end
