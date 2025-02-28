require 'rails_helper'

describe API::Entities::SearchResult do
  subject(:search_result) { described_class.represent(claim) }

  let(:claim) do
    MockClaim.new(
      id: '19932',
      uuid: 'aec3900f-3e82-4c4f-a7cd-498ad45f11f8',
      scheme: 'agfs',
      scheme_type: 'Advocate',
      case_number: 'T20160427',
      state: 'submitted',
      court_name: 'Newcastle',
      case_type: 'Contempt',
      total: '426.36',
      disk_evidence: false,
      external_user: 'Theodore Schumm',
      maat_references: '2320144',
      defendants: 'Junius Lesch',
      fees: '1.0~Basic fee~Fee::BasicFeeType, 34.0~Pages of prosecution evidence~Fee::BasicFeeType',
      last_submitted_at: '2017-07-06 09:33:30.932017',
      class_letter: 'F',
      is_fixed_fee: false,
      fee_type_code: 'GRRAK',
      graduated_fee_types: 'GRTRL,GRRTR,GRGLT,GRDIS,GRRAK,GRCBR',
      injection_errors: '{"errors":[]}'
    )
  end

  before do
    stub_const(
      'MockClaim', Struct.new(:id, :uuid, :scheme, :scheme_type, :case_number, :state, :court_name, :case_type, :total,
                              :disk_evidence, :external_user, :maat_references, :defendants, :fees, :last_submitted_at,
                              :class_letter, :is_fixed_fee, :fee_type_code, :graduated_fee_types, :injection_errors,
                              :allocation_type, :last_injection_succeeded, :transfer_stage_id)
    )
  end

  describe 'exposures' do
    it { is_expected.to expose :id }
    it { is_expected.to expose :uuid }
    it { is_expected.to expose :scheme }
    it { is_expected.to expose :scheme_type }
    it { is_expected.to expose :case_number }
    it { is_expected.to expose :state }
    it { is_expected.to expose :state_display }
    it { is_expected.to expose :court_name }
    it { is_expected.to expose :case_type }
    it { is_expected.to expose :total }
    it { is_expected.to expose :total_display }
    it { is_expected.to expose :external_user }
    it { is_expected.to expose :last_submitted_at }
    it { is_expected.to expose :last_submitted_at_display }
    it { is_expected.to expose :defendants }
    it { is_expected.to expose :maat_references }
    it { is_expected.to expose :injection_errors }
  end

  describe 'filters' do
    subject(:filter) { JSON.parse(search_result.to_json, symbolize_names: true)[:filter] }

    let(:result) do
      {
        disk_evidence: 0,
        redetermination: 0,
        fixed_fee: 0,
        awaiting_written_reasons: 0,
        cracked: 0,
        trial: 0,
        guilty_plea: 0,
        graduated_fees: 0,
        interim_fees: 0,
        lgfs_warrants: 0,
        agfs_warrants: 0,
        interim_disbursements: 0,
        risk_based_bills: 0,
        injection_errored: 0,
        cav_warning: 0,
        supplementary: 0,
        agfs_hardship: 0,
        lgfs_hardship: 0,
        clar_fees_warning: 0,
        additional_prep_fee_warning: 0
      }
    end

    shared_examples 'returns expected JSON filter values' do
      it { is_expected.to eql result }
    end

    context 'with an AGFS claim' do
      context 'when passed a submitted case with a graduated fee' do
        before { result.merge!(graduated_fees: 1) }

        include_examples 'returns expected JSON filter values'
      end

      context 'when passed a redetermination case with a graduated fee' do
        before do
          claim.state = 'redetermination'
          result.merge!(redetermination: 1)
        end

        include_examples 'returns expected JSON filter values'
      end

      context 'when passed an advocate claims with an injection attempt error' do
        before do
          claim.injection_errors = '{"errors":[{"error":"Claim not injected"}]}'
          result.merge!(graduated_fees: 1, injection_errored: 1)
        end

        include_examples 'returns expected JSON filter values'
      end

      context 'when passed an advocate claims with a CAV value and without an injection attempt error' do
        before do
          claim.last_injection_succeeded = 'true'
          claim.fees = '100.0~Conferences and views~Fee::BasicFeeType'
          result.merge!(graduated_fees: 1, cav_warning: 1)
        end

        include_examples 'returns expected JSON filter values'
      end

      context 'when passed an advocate claims with CLAR fees and without an injection attempt error' do
        before do
          claim.last_injection_succeeded = 'true'
          claim.fees = '3.0~Paper heavy case~Fee::MiscFeeType'
          result.merge!(graduated_fees: 1, clar_fees_warning: 1)
        end

        include_examples 'returns expected JSON filter values'
      end

      context 'when passed an advocate claim with an Additional Prep fee and without an injection attempt error' do
        before do
          claim.last_injection_succeeded = 'true'
          claim.fees = '1.0~Additional preparation fee~Fee::MiscFeeType'
          result.merge!(graduated_fees: 1, additional_prep_fee_warning: 1)
        end

        include_examples 'returns expected JSON filter values'
      end

      context 'when passed an advocate interim/warrant claim' do
        before do
          claim.case_type = 'Warrant'
          claim.fees = '0.0~Warrant Fee~Fee::WarrantFeeType'
          claim.fee_type_code = nil
          result.merge!(agfs_warrants: 1)
        end

        include_examples 'returns expected JSON filter values'
      end

      context 'when passed an advocate supplementary claim' do
        before do
          claim.case_type = 'Supplementary'
          claim.fees = '0.0~Warrant Fee~Fee::WarrantFeeType'
          claim.fee_type_code = nil
          result.merge!(supplementary: 1)
        end

        include_examples 'returns expected JSON filter values'
      end

      context 'when passed an advocate hardship claim' do
        before do
          claim.scheme_type = 'AdvocateHardship'
          claim.fees = '1.0~Basic fee~Fee::BasicFeeType'
          result.merge!(graduated_fees: 1, agfs_hardship: 1)
        end

        include_examples 'returns expected JSON filter values'
      end

      context 'with a redetermination state' do
        before do
          claim.scheme_type = 'AdvocateHardship'
          claim.fees = '1.0~Basic fee~Fee::BasicFeeType'
          claim.state = 'redetermination'
          result.merge!(graduated_fees: 0, redetermination: 0, agfs_hardship: 1)
        end

        include_examples 'returns expected JSON filter values'
      end
    end

    context 'with an LGFS claim' do
      let(:claim) do
        MockClaim.new(
          id: '19932',
          uuid: 'aec3900f-3e82-4c4f-a7cd-498ad45f11f8',
          scheme: 'lgfs',
          scheme_type: 'Final',
          case_number: 'T20160427',
          state: 'submitted',
          court_name: 'Chester',
          case_type: 'Guilty plea',
          total: '556.11',
          disk_evidence: false,
          external_user: 'Ozella Adams',
          maat_references: '5782148',
          defendants: 'Vallie King',
          fees: '30.0~Guilty plea~Fee::GraduatedFeeType',
          last_submitted_at: '2017-07-18 09:19:42.860977',
          class_letter: 'H',
          is_fixed_fee: false,
          fee_type_code: 'GRGLT',
          graduated_fee_types: 'GRTRL,GRRTR,GRGLT,GRDIS,GRRAK,GRCBR',
          injection_errors: '{"errors":[]}'
        )
      end

      context 'when passed a litigator case with a risk based bill' do
        before { result.merge!(guilty_plea: 1, graduated_fees: 1, risk_based_bills: 1) }

        include_examples 'returns expected JSON filter values'
      end

      context 'when passed a litigator case with a risk based transfer bill' do
        before do
          claim.case_type = nil
          claim.scheme_type = 'Transfer'
          claim.fees = '30.0~~Fee::TransferFeeType'
          claim.transfer_stage_id = 10
          result.merge!(guilty_plea: 0, graduated_fees: 1, risk_based_bills: 1)
        end

        include_examples 'returns expected JSON filter values'
      end

      context 'when passed a litigator case with a redetermined Final fee' do
        before do
          claim.case_type = 'Committal for Sentence'
          claim.state = 'redetermination'
          claim.fees = '0.0~Committal for sentence hearings~Fee::FixedFeeType'
          result.merge!(redetermination: 1)
        end

        include_examples 'returns expected JSON filter values'
      end

      context 'when passed a litigator case with a Final graduated fee' do
        before do
          claim.case_type = 'Trial'
          claim.fees = '1.0~Basic fee~Fee::BasicFeeType'
          result.merge!(trial: 1, graduated_fees: 1)
        end

        include_examples 'returns expected JSON filter values'
      end

      context 'when passed a litigator case with a Final fixed fee' do
        before do
          claim.case_type = 'Elected cases not proceeded'
          claim.fees = '0.0~Elected case not proceeded~Fee::FixedFeeType'
          claim.is_fixed_fee = true,
                               claim.fee_type_code = 'FXENP'
          result.merge!(fixed_fee: 1)
        end

        include_examples 'returns expected JSON filter values'
      end

      context 'when passed a litigator Disbursement only Interim fee' do
        before do
          claim.scheme_type = 'Interim'
          claim.case_type = 'Trial'
          claim.fees = '0.0~Disbursement only~Fee::InterimFeeType'
          result.merge!(trial: 1, graduated_fees: 1, interim_disbursements: 1)
        end

        include_examples 'returns expected JSON filter values'
      end

      context 'when passed a litigator warrant Interim fee' do
        before do
          claim.scheme_type = 'Interim'
          claim.case_type = 'Trial'
          claim.fees = '0.0~Warrant~Fee::InterimFeeType'
          result.merge!(trial: 1, graduated_fees: 1, lgfs_warrants: 1)
        end

        include_examples 'returns expected JSON filter values'
      end

      context 'when passed a litigator Interim fee' do
        before do
          claim.scheme_type = 'Interim'
          claim.case_type = 'Trial'
          claim.fees = '19.0~Effective PCMH~Fee::InterimFeeType'
          result.merge!(trial: 1, graduated_fees: 1, interim_fees: 1)
        end

        include_examples 'returns expected JSON filter values'
      end

      context 'when passed a litigator Transfer fixed fee' do
        before do
          claim.fee_type_code = nil
          claim.allocation_type = 'Fixed'
          claim.scheme_type = 'Transfer'
          claim.case_type = 'Transfer'
          claim.fees = '44.0~Transfer~Fee::TransferFeeType'
          result.merge!(fixed_fee: 1)
        end

        include_examples 'returns expected JSON filter values'
      end

      context 'when passed a litigator Transfer grad fee' do
        before do
          claim.fee_type_code = nil
          claim.allocation_type = 'Grad'
          claim.scheme_type = 'Transfer'
          claim.case_type = 'Transfer'
          claim.fees = '0.0~Transfer~Fee::TransferFeeType'
          result.merge!(graduated_fees: 1)
        end

        include_examples 'returns expected JSON filter values'
      end

      context 'when passed a litigator claim with CLAR fees and without an injection attempt error' do
        before do
          claim.last_injection_succeeded = 'true'
          claim.scheme_type = 'Final'
          claim.case_type = 'Trial'
          claim.fees = '1001.0~Trial~Fee::GraduatedFeeType,59.59~Unused materials (up to 3 hours)~Fee::MiscFeeType'
          result.merge!(trial: 1, graduated_fees: 1, clar_fees_warning: 1)
        end

        include_examples 'returns expected JSON filter values'
      end

      context 'when passed a litigator hardship claim with a submitted state' do
        before do
          claim.scheme_type = 'LitigatorHardship'
          claim.case_type = 'Trial'
          claim.fees = '1000.0~Hardship~Fee::HardshipFeeType'
          result.merge!(graduated_fees: 1, lgfs_hardship: 1, trial: 1)
        end

        include_examples 'returns expected JSON filter values'
      end

      context 'when passed a litigator hardship claim with a redetermination state' do
        before do
          claim.scheme_type = 'LitigatorHardship'
          claim.case_type = 'Trial'
          claim.fees = '1000.0~Hardship~Fee::HardshipFeeType'
          claim.state = 'redetermination'
          result.merge!(redetermination: 0, lgfs_hardship: 1, graduated_fees: 0, trial: 0)
        end

        include_examples 'returns expected JSON filter values'
      end
    end
  end
end
