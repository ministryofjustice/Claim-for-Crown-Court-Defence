require 'rails_helper'

RSpec.shared_context 'with a pre CLAR rep order date' do
  let(:pre_clar_date) { Settings.clar_release_date.end_of_day - 1.day }

  before do
    allow(claim)
      .to receive(:earliest_representation_order_date)
      .and_return(pre_clar_date)
  end
end

RSpec.shared_context 'with a post CLAR rep order date' do
  let(:post_clar_date) { Settings.clar_release_date.beginning_of_day }

  before do
    allow(claim)
      .to receive(:earliest_representation_order_date)
      .and_return(post_clar_date)
  end
end

RSpec.shared_examples 'with AGFS scheme 9 and 10+ fetch excludes supplementary-only' do |claim_factory|
  context 'when scheme 9 claim' do
    let(:claim) { create(claim_factory, :agfs_scheme_9) }

    it { is_expected.to have_at_least(1).items }

    it 'returns only misc fee types for AGFS scheme 9 without supplementary-only fee types' do
      is_expected.to match_array Fee::MiscFeeType.agfs_scheme_9s.without_supplementary_only.map(&:unique_code).reject
    end
  end

  context 'when scheme 10+ claim' do
    let(:claim) { create(claim_factory, :agfs_scheme_10) }

    it { is_expected.to have_at_least(1).items }

    it 'returns only misc fee types for AGFS scheme 10+ without supplementary-only fee types' do
      is_expected.to match_array Fee::MiscFeeType.agfs_scheme_10s.without_supplementary_only.map(&:unique_code)
    end
  end
end

RSpec.describe Claims::FetchEligibleMiscFeeTypes, type: :service do
  before(:all) do
    seed_case_types
    seed_fee_types
  end

  after(:all) do
    clean_database
  end

  let(:unused_materials_types) { %w[MIUMU MIUMO] }
  let(:section_twenty_eight_types) { %w[MISTE] }
  let(:supplementary_only_types) { %w[MISAF MIPCM] }
  let(:additional_prep_fee_types) { %w[MIAPF] }

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

      it { is_expected.to be_nil }
    end

    context 'with LGFS claim' do
      subject(:unique_codes) { call.map(&:unique_code) }

      context 'with final claim' do
        let(:claim) { create(:litigator_claim, :without_fees, case_type:) }

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
              include_context 'with a pre CLAR rep order date'

              it { is_expected.to match_array %w[MICJA MICJP MIEVI MISPF] }
            end

            context 'with rep order post CLAR' do
              include_context 'with a post CLAR rep order date'

              it { is_expected.to match_array %w[MICJA MICJP MIEVI MISPF MIUMU MIUMO] }
            end
          end

          context 'with "non-trial" fee claim' do
            include_context 'with a post CLAR rep order date'

            context 'when case type is Guilty plea' do
              let(:case_type) { CaseType.find_by(fee_type_code: 'GRGLT') }

              it { is_expected.to match_array %w[MICJA MICJP MIEVI MISPF] }
            end
          end
        end
      end

      context 'with hardship fee claim' do
        let(:claim) { create(:litigator_hardship_claim, case_stage:) }

        context 'when rep order is post CLAR' do
          include_context 'with a post CLAR rep order date'

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
          include_context 'with a pre CLAR rep order date'

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
          include_context 'with a pre CLAR rep order date'

          it 'returns all LGFS misc fee types except defendant uplifts' do
            is_expected.to match_array %w[MICJA MICJP MIEVI MISPF]
          end
        end

        context 'with rep order post CLAR' do
          include_context 'with a post CLAR rep order date'

          it 'returns all LGFS misc fee types except defendant uplifts' do
            is_expected.to match_array %w[MICJA MICJP MIEVI MISPF MIUMU MIUMO]
          end
        end

        context 'with rep order post CLAR and a guilty plea' do
          include_context 'with a post CLAR rep order date'

          before do
            claim.transfer_detail.update(
              case_conclusion_id: Claim::TransferBrain.case_conclusion_id('Guilty plea')
            )
          end

          it 'returns all LGFS misc fee types except defendant uplifts' do
            is_expected.to match_array %w[MICJA MICJP MIEVI MISPF]
          end
        end
      end
    end

    context 'with AGFS claim' do
      let(:claim) { create(:advocate_claim) }

      it { is_expected.to all(be_a(Fee::MiscFeeType)) }

      context 'with final claim' do
        subject(:unique_codes) { call.map(&:unique_code) }

        include_examples 'with AGFS scheme 9 and 10+ fetch excludes supplementary-only', :advocate_claim

        context 'with a scheme 12 claim' do
          let(:claim) { create(:advocate_claim, :agfs_scheme_12, case_type:) }

          context 'with "trial" case type' do
            let(:case_type) { CaseType.find_by(fee_type_code: 'GRTRL') }

            it { is_expected.not_to include(*supplementary_only_types) }
            it { is_expected.to include(*unused_materials_types) }
            it { is_expected.not_to include(*section_twenty_eight_types) }
            it { is_expected.not_to include(*additional_prep_fee_types) }

            it 'returns misc fee types for AGFS scheme 12 without supplementary-only fee types' do
              is_expected.to match_array Fee::MiscFeeType.agfs_scheme_12s.without_supplementary_only.map(&:unique_code)
            end
          end

          context 'with "non-trial" case type' do
            let(:case_type) { CaseType.find_by(fee_type_code: 'GRGLT') }

            it { is_expected.not_to include(*supplementary_only_types) }
            it { is_expected.not_to include(*unused_materials_types) }
            it { is_expected.not_to include(*section_twenty_eight_types) }
            it { is_expected.not_to include(*additional_prep_fee_types) }

            it 'returns misc fee types for AGFS scheme 12 without supplementary-only or trial-only fee types' do
              is_expected.to match_array(
                Fee::MiscFeeType.agfs_scheme_12s.without_supplementary_only.without_trial_fee_only.map(&:unique_code)
              )
            end
          end
        end

        context 'with a scheme 13 claim' do
          let(:claim) { create(:advocate_claim, :agfs_scheme_13, case_type:) }

          context 'with "trial" case type' do
            let(:case_type) { CaseType.find_by(fee_type_code: 'GRTRL') }

            it { is_expected.not_to include(*supplementary_only_types) }
            it { is_expected.to include(*unused_materials_types) }
            it { is_expected.not_to include(*section_twenty_eight_types) }
            it { is_expected.not_to include(*additional_prep_fee_types) }

            it 'returns misc fee types for AGFS scheme 13 without supplementary-only fee types' do
              is_expected.to match_array Fee::MiscFeeType.agfs_scheme_13s.without_supplementary_only.map(&:unique_code)
            end
          end

          context 'with "non-trial" case type' do
            let(:case_type) { CaseType.find_by(fee_type_code: 'GRGLT') }

            it { is_expected.not_to include(*supplementary_only_types) }
            it { is_expected.not_to include(*unused_materials_types) }
            it { is_expected.not_to include(*section_twenty_eight_types) }
            it { is_expected.not_to include(*additional_prep_fee_types) }

            it 'returns misc fee types for AGFS scheme 13 without supplementary-only or trial-only fee types' do
              is_expected.to match_array(
                Fee::MiscFeeType.agfs_scheme_13s.without_supplementary_only.without_trial_fee_only.map(&:unique_code)
              )
            end
          end
        end

        context 'with a scheme 14 claim' do
          let(:claim) { create(:advocate_claim, :agfs_scheme_14, case_type:) }

          context 'with "trial" case type' do
            let(:case_type) { CaseType.find_by(fee_type_code: 'GRTRL') }

            it { is_expected.not_to include(*supplementary_only_types) }
            it { is_expected.to include(*unused_materials_types) }
            it { is_expected.to include(*section_twenty_eight_types) }
            it { is_expected.not_to include(*additional_prep_fee_types) }

            it 'returns misc fee types for AGFS scheme 14 without supplementary-only fee types' do
              is_expected.to match_array Fee::MiscFeeType.agfs_scheme_14s.without_supplementary_only.map(&:unique_code)
            end
          end

          context 'with "non-trial" case type' do
            let(:case_type) { CaseType.find_by(fee_type_code: 'GRGLT') }

            it { is_expected.not_to include(*supplementary_only_types) }
            it { is_expected.not_to include(*unused_materials_types) }
            it { is_expected.not_to include(*section_twenty_eight_types) }
            it { is_expected.not_to include(*additional_prep_fee_types) }

            it 'returns misc fee types for AGFS scheme 14 without supplementary-only or trial-only fee types' do
              is_expected.to match_array(
                Fee::MiscFeeType.agfs_scheme_14s.without_supplementary_only.without_trial_fee_only.map(&:unique_code)
              )
            end
          end
        end

        context 'with a scheme 15 claim' do
          let(:claim) { create(:advocate_claim, :agfs_scheme_15, case_type:) }

          context 'with "trial" case type' do
            let(:case_type) { CaseType.find_by(fee_type_code: 'GRTRL') }

            it { is_expected.not_to include(*supplementary_only_types) }
            it { is_expected.to include(*unused_materials_types) }
            it { is_expected.to include(*section_twenty_eight_types) }
            it { is_expected.to include(*additional_prep_fee_types) }

            it 'returns misc fee types for AGFS scheme 15 without supplementary-only fee types' do
              is_expected.to match_array Fee::MiscFeeType.agfs_scheme_15s.without_supplementary_only.map(&:unique_code)
            end
          end

          context 'with "non-trial" case type' do
            let(:case_type) { CaseType.find_by(fee_type_code: 'GRGLT') }

            it { is_expected.not_to include(*supplementary_only_types) }
            it { is_expected.not_to include(*unused_materials_types) }
            it { is_expected.not_to include(*section_twenty_eight_types) }
            it { is_expected.not_to include(*additional_prep_fee_types) }

            it 'returns misc fee types for AGFS scheme 15 without supplementary-only or trial-only fee types' do
              is_expected.to match_array(
                Fee::MiscFeeType.agfs_scheme_15s.without_supplementary_only.without_trial_fee_only.map(&:unique_code)
              )
            end
          end
        end
      end

      context 'with hardship claim' do
        subject(:unique_codes) { call.map(&:unique_code) }

        include_examples 'with AGFS scheme 9 and 10+ fetch excludes supplementary-only', :advocate_hardship_claim

        context 'with scheme 12 claim' do
          let(:claim) { create(:advocate_hardship_claim, :agfs_scheme_12, case_stage:) }

          context 'with "trial" case stage' do
            let(:case_stage) { create(:case_stage, :trial_not_sentenced) }

            it { is_expected.not_to include(*supplementary_only_types) }
            it { is_expected.to include(*unused_materials_types) }

            it 'returns misc fee types for AGFS scheme 12 without supplementary-only fee types' do
              is_expected.to match_array Fee::MiscFeeType.agfs_scheme_12s.without_supplementary_only.map(&:unique_code)
            end
          end

          context 'with "non-trial" case stage' do
            let(:case_stage) { create(:case_stage, :guilty_plea_not_sentenced) }

            it { is_expected.not_to include(*supplementary_only_types) }
            it { is_expected.not_to include(*unused_materials_types) }

            it 'returns misc fee types for AGFS scheme 12 without supplementary-only or trial-only fee types' do
              is_expected.to match_array(
                Fee::MiscFeeType.agfs_scheme_12s.without_supplementary_only.without_trial_fee_only.map(&:unique_code)
              )
            end
          end
        end

        context 'with scheme 13 claim' do
          let(:claim) { create(:advocate_hardship_claim, :agfs_scheme_13, case_stage:) }

          context 'with "trial" case stage' do
            let(:case_stage) { create(:case_stage, :trial_not_sentenced) }

            it { is_expected.not_to include(*supplementary_only_types) }
            it { is_expected.to include(*unused_materials_types) }

            it 'returns misc fee types for AGFS scheme 13 without supplementary-only fee types' do
              is_expected.to match_array Fee::MiscFeeType.agfs_scheme_13s.without_supplementary_only.map(&:unique_code)
            end
          end

          context 'with "non-trial" case stage' do
            let(:case_stage) { create(:case_stage, :guilty_plea_not_sentenced) }

            it { is_expected.not_to include(*supplementary_only_types) }
            it { is_expected.not_to include(*unused_materials_types) }

            it 'returns misc fee types for AGFS scheme 13 without supplementary-only or trial-only fee types' do
              is_expected.to match_array(
                Fee::MiscFeeType.agfs_scheme_13s.without_supplementary_only.without_trial_fee_only.map(&:unique_code)
              )
            end
          end
        end
      end

      context 'with supplementary claim' do
        subject(:call) { described_class.new(claim).call.map(&:unique_code) }

        let(:scheme_9_supplementary_fee_types) do
          %w[MISAF MISAU MIPCM MISPF MIWPF MIDTH MIDTW MIDHU MIDWU MIDSE MIDSU MISHR MISHU]
        end

        let(:supplementary_fee_types) { scheme_9_supplementary_fee_types + ['MIFCM'] }
        let(:clar_fee_types) { %w[MIPHC MIUMU MIUMO] }
        let(:scheme_12_fee_types) { supplementary_fee_types + clar_fee_types }
        let(:scheme_14_fee_types) { scheme_12_fee_types + section_twenty_eight_types }
        let(:scheme_15_fee_types) { scheme_14_fee_types + additional_prep_fee_types }

        context 'when scheme 9 claim' do
          let(:claim) { create(:advocate_supplementary_claim, :agfs_scheme_9, with_misc_fee: false) }

          it { is_expected.to match_array scheme_9_supplementary_fee_types }
        end

        context 'when scheme 10+ claim' do
          let(:claim) { create(:advocate_supplementary_claim, :agfs_scheme_10, with_misc_fee: false) }

          it { is_expected.to match_array supplementary_fee_types }
        end

        context 'when CLAR scheme 12 claim' do
          let(:claim) { create(:advocate_supplementary_claim, :agfs_scheme_12, with_misc_fee: false, case_type: nil) }

          it { is_expected.to match_array(scheme_12_fee_types) }
        end

        context 'when CLAIR scheme 13 claim' do
          let(:claim) { create(:advocate_supplementary_claim, :agfs_scheme_13, with_misc_fee: false, case_type: nil) }

          it { is_expected.to match_array(scheme_12_fee_types) }
        end

        context 'when scheme 14 claim' do
          let(:claim) { create(:advocate_supplementary_claim, :agfs_scheme_14, with_misc_fee: false, case_type: nil) }

          it { is_expected.to match_array(scheme_14_fee_types) }
        end

        context 'when scheme 15 claim' do
          let(:claim) { create(:advocate_supplementary_claim, :agfs_scheme_15, with_misc_fee: false, case_type: nil) }

          it { is_expected.to match_array(scheme_15_fee_types) }
        end
      end
    end
  end
end
