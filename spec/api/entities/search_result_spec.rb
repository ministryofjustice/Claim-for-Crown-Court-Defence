require 'rails_helper'

describe API::Entities::SearchResult do
  subject(:search_result) { described_class.represent(claim) }

  context 'exposures' do
    let(:claim) do
      OpenStruct.new(
        'id' => '19932',
        'uuid' => 'aec3900f-3e82-4c4f-a7cd-498ad45f11f8',
        'scheme' => 'agfs',
        'scheme_type' => 'Advocate',
        'case_number' => 'T20160427',
        'state' => 'submitted',
        'court_name' => 'Newcastle',
        'case_type' => 'Contempt',
        'total' => '426.36',
        'disk_evidence' => false,
        'external_user' => 'Theodore Schumm',
        'maat_references' => '2320144',
        'defendants' => 'Junius Lesch',
        'fees' => '0.0~Daily attendance fee (3 to 40)~Fee::BasicFeeType, 0.0~Daily attendance fee (41 to 50)~Fee::BasicFeeType, 0.0~Daily attendance fee (51+)~Fee::BasicFeeType, 0.0~Standard appearance fee~Fee::BasicFeeType, 0.0~Plea and case management hearing~Fee::BasicFeeType, 0.0~Conferences and views~Fee::BasicFeeType, 0.0~Number of defendants uplift~Fee::BasicFeeType, 0.0~Number of cases uplift~Fee::BasicFeeType, 0.0~Number of prosecution witnesses~Fee::BasicFeeType, 1.0~Basic fee~Fee::BasicFeeType, 34.0~Pages of prosecution evidence~Fee::BasicFeeType',
        'last_submitted_at' => '2017-07-06 09:33:30.932017',
        'class_letter' => 'F',
        'is_fixed_fee' => false,
        'fee_type_code' => 'GRRAK',
        'graduated_fee_types' => 'GRTRL,GRRTR,GRGLT,GRDIS,GRRAK,GRCBR',
        'injection_errors' => '{"errors":[]}'
      )
    end

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
          clar_fees_warning: 0
        }
      end

      shared_examples 'returns expected JSON filter values' do
        it 'returns expected JSON filterable values' do
          is_expected.to eql result
        end
      end

      context 'when passed a submitted case with a graduated fee ' do
        let(:claim) { OpenStruct.new('id' => '19932', 'uuid' => 'aec3900f-3e82-4c4f-a7cd-498ad45f11f8', 'scheme' => 'agfs', 'scheme_type' => 'Advocate', 'case_number' => 'T20160427', 'state' => 'submitted', 'court_name' => 'Newcastle', 'case_type' => 'Contempt', 'total' => '426.36', 'disk_evidence' => false, 'external_user' => 'Theodore Schumm', 'maat_references' => '2320144', 'defendants' => 'Junius Lesch', 'fees' => '0.0~Daily attendance fee (3 to 40)~Fee::BasicFeeType, 0.0~Daily attendance fee (41 to 50)~Fee::BasicFeeType, 0.0~Daily attendance fee (51+)~Fee::BasicFeeType, 0.0~Standard appearance fee~Fee::BasicFeeType, 0.0~Plea and case management hearing~Fee::BasicFeeType, 0.0~Conferences and views~Fee::BasicFeeType, 0.0~Number of defendants uplift~Fee::BasicFeeType, 0.0~Number of cases uplift~Fee::BasicFeeType, 0.0~Number of prosecution witnesses~Fee::BasicFeeType, 1.0~Basic fee~Fee::BasicFeeType, 34.0~Pages of prosecution evidence~Fee::BasicFeeType', 'last_submitted_at' => '2017-07-06 09:33:30.932017', 'class_letter' => 'F', 'is_fixed_fee' => false, 'fee_type_code' => 'GRRAK', 'graduated_fee_types' => 'GRTRL,GRRTR,GRGLT,GRDIS,GRRAK,GRCBR') }
        before { result.merge!(graduated_fees: 1) }
        include_examples 'returns expected JSON filter values'
      end

      context 'when passed a redetermination case with a graduated fee ' do
        let(:claim) { OpenStruct.new('id' => '19932', 'uuid' => 'aec3900f-3e82-4c4f-a7cd-498ad45f11f8', 'scheme' => 'agfs', 'scheme_type' => 'Advocate', 'case_number' => 'T20160427', 'state' => 'redetermination', 'court_name' => 'Newcastle', 'case_type' => 'Contempt', 'total' => '426.36', 'disk_evidence' => false, 'external_user' => 'Theodore Schumm', 'maat_references' => '2320144', 'defendants' => 'Junius Lesch', 'fees' => '0.0~Daily attendance fee (3 to 40)~Fee::BasicFeeType, 0.0~Daily attendance fee (41 to 50)~Fee::BasicFeeType, 0.0~Daily attendance fee (51+)~Fee::BasicFeeType, 0.0~Standard appearance fee~Fee::BasicFeeType, 0.0~Plea and case management hearing~Fee::BasicFeeType, 0.0~Conferences and views~Fee::BasicFeeType, 0.0~Number of defendants uplift~Fee::BasicFeeType, 0.0~Number of cases uplift~Fee::BasicFeeType, 0.0~Number of prosecution witnesses~Fee::BasicFeeType, 1.0~Basic fee~Fee::BasicFeeType, 34.0~Pages of prosecution evidence~Fee::BasicFeeType', 'last_submitted_at' => '2017-07-06 09:33:30.932017', 'class_letter' => 'F', 'is_fixed_fee' => false, 'fee_type_code' => 'GRRAK', 'graduated_fee_types' => 'GRTRL,GRRTR,GRGLT,GRDIS,GRRAK,GRCBR') }
        before { result.merge!(redetermination: 1) }
        include_examples 'returns expected JSON filter values'
      end

      context 'when passed a litigator case with a risk based bill' do
        let(:claim) { OpenStruct.new('id' => '113336', 'uuid' => '446fd8db-4441-4726-857c-3e80e440f5a2', 'scheme' => 'lgfs', 'scheme_type' => 'Final', 'case_number' => 'T20170329', 'state' => 'submitted', 'court_name' => 'Chester', 'case_type' => 'Guilty plea', 'total' => '556.11', 'disk_evidence' => false, 'external_user' => 'Ozella Adams', 'maat_references' => '5782148', 'defendants' => 'Vallie King', 'fees' => '30.0~Guilty plea~Fee::GraduatedFeeType', 'last_submitted_at' => '2017-07-18 09:19:42.860977', 'class_letter' => 'H', 'is_fixed_fee' => false, 'fee_type_code' => 'GRGLT', 'graduated_fee_types' => 'GRTRL,GRRTR,GRGLT,GRDIS,GRRAK,GRCBR') }
        before { result.merge!(guilty_plea: 1, graduated_fees: 1, risk_based_bills: 1) }
        include_examples 'returns expected JSON filter values'
      end

      context 'when passed a litigator case with a risk based transfer bill' do
        let(:claim) { OpenStruct.new('id' => '113336', 'uuid' => '446fd8db-4441-4726-857c-3e80e440f5a2', 'scheme' => 'lgfs', 'scheme_type' => 'Transfer', 'case_number' => 'T20170329', 'state' => 'submitted', 'court_name' => 'Chester', 'total' => '556.11', 'disk_evidence' => false, 'external_user' => 'Ozella Adams', 'maat_references' => '5782148', 'defendants' => 'Vallie King', 'fees' => '30.0~~Fee::TransferFeeType', 'last_submitted_at' => '2017-07-18 09:19:42.860977', 'class_letter' => 'G', 'is_fixed_fee' => false, 'fee_type_code' => 'GRGLT', 'graduated_fee_types' => 'GRTRL,GRRTR,GRGLT,GRDIS,GRRAK,GRCBR', 'transfer_stage_id' => 10) }
        before { result.merge!(guilty_plea: 0, graduated_fees: 1, risk_based_bills: 1) }
        include_examples 'returns expected JSON filter values'
      end

      context 'when passed a litigator case with a final fee' do
        let(:claim) { OpenStruct.new('id' => '132506', 'uuid' => '1344fb35-2337-4d22-b45a-5389315d06c5', 'scheme' => 'lgfs', 'scheme_type' => 'Final', 'case_number' => 'S20170495', 'state' => 'redetermination', 'court_name' => 'Newcastle', 'case_type' => 'Committal for Sentence', 'total' => '309.82', 'disk_evidence' => false, 'external_user' => 'Ole Hermann', 'maat_references' => '5782148', 'defendants' => 'Zetta Rau', 'fees' => '0.0~Committal for sentence hearings~Fee::FixedFeeType', 'last_submitted_at' => '2017-07-18 09:19:42.860977', 'class_letter' => 'E', 'is_fixed_fee' => true, 'fee_type_code' => 'FXCSE', 'graduated_fee_types' => 'GRTRL,GRRTR,GRGLT,GRDIS,GRRAK,GRCBR') }
        before { result.merge!(redetermination: 1) }
        include_examples 'returns expected JSON filter values'
      end

      context 'when passed a litigator case with Final fee' do
        let(:claim) { OpenStruct.new('id' => '180772', 'uuid' => 'ef682b0b-82ef-4908-9b3f-3cee19acc148', 'scheme' => 'lgfs', 'scheme_type' => 'Final', 'case_number' => 'T20170981', 'state' => 'submitted', 'court_name' => 'Newcastle', 'case_type' => 'Elected cases not proceeded', 'total' => '396.4', 'disk_evidence' => false, 'external_user' => 'Name Padberg', 'maat_references' => '5924967', 'defendants' => 'Maybell Bahringer', 'fees' => '0.0~Elected case not proceeded~Fee::FixedFeeType', 'last_submitted_at' => '2017-12-08 14:55:58.416695', 'class_letter' => 'H', 'is_fixed_fee' => true, 'fee_type_code' => 'FXENP', 'graduated_fee_types' => 'GRTRL,GRRTR,GRGLT,GRDIS,GRRAK,GRCBR') }
        before { result.merge!(fixed_fee: 1) }
        include_examples 'returns expected JSON filter values'
      end

      context 'when passed a litigator Disbursement only Interim fee' do
        let(:claim) { OpenStruct.new('id' => '179473', 'uuid' => '7bca9dd7-0a32-442c-b399-85a2379609ad', 'scheme' => 'lgfs', 'scheme_type' => 'Interim', 'case_number' => 'T20170276', 'state' => 'submitted', 'court_name' => 'Worcester', 'case_type' => 'Trial', 'total' => '4652.64', 'disk_evidence' => false, 'external_user' => 'Stacey Bosco', 'maat_references' => '5853600', 'defendants' => 'Jordyn Marquardt', 'fees' => '0.0~Disbursement only~Fee::InterimFeeType', 'last_submitted_at' => '07/12/2017  10:30:54', 'class_letter' => 'D', 'is_fixed_fee' => false, 'fee_type_code' => 'GRTRL', 'graduated_fee_types' => 'GRTRL,GRRTR,GRGLT,GRDIS,GRRAK,GRCBR') }
        before { result.merge!(trial: 1, graduated_fees: 1, interim_disbursements: 1) }
        include_examples 'returns expected JSON filter values'
      end

      context 'when passed a litigator warrant Interim fee' do
        let(:claim) { OpenStruct.new('id' => '179818', 'uuid' => '887cbd94-3f48-4955-8646-918de4db3617', 'scheme' => 'lgfs', 'scheme_type' => 'Interim', 'case_number' => 'T20170081', 'state' => 'submitted', 'court_name' => 'Cambridge', 'case_type' => 'Trial', 'total' => '667.33', 'disk_evidence' => false, 'external_user' => 'Fernando Zboncak', 'maat_references' => '5663494', 'defendants' => 'Reta Stark', 'fees' => '0.0~Warrant~Fee::InterimFeeType', 'last_submitted_at' => '07/12/2017  12:58:29', 'class_letter' => 'B', 'is_fixed_fee' => false, 'fee_type_code' => 'GRTRL', 'graduated_fee_types' => 'GRTRL,GRRTR,GRGLT,GRDIS,GRRAK,GRCBR') }
        before { result.merge!(trial: 1, graduated_fees: 1, lgfs_warrants: 1) }
        include_examples 'returns expected JSON filter values'
      end

      context 'when passed a litigator Interim fee' do
        let(:claim) { OpenStruct.new('id' => '180773', 'uuid' => 'c4a9bf51-ffe1-40eb-8399-f9ae2510b417', 'scheme' => 'lgfs', 'scheme_type' => 'Interim', 'case_number' => 'T20171115', 'state' => 'submitted', 'court_name' => 'Liverpool', 'case_type' => 'Trial', 'total' => '213.3', 'disk_evidence' => false, 'external_user' => 'Eldridge Muller', 'maat_references' => '5841779', 'defendants' => 'Destini Thiel', 'fees' => '19.0~Effective PCMH~Fee::InterimFeeType', 'last_submitted_at' => '11/12/2017  10:37:06', 'class_letter' => 'H', 'is_fixed_fee' => false, 'fee_type_code' => 'GRTRL', 'graduated_fee_types' => 'GRTRL,GRRTR,GRGLT,GRDIS,GRRAK,GRCBR') }
        before { result.merge!(trial: 1, graduated_fees: 1, interim_fees: 1) }
        include_examples 'returns expected JSON filter values'
      end

      context 'when passed a litigator Transfer fixed fee' do
        let(:claim) { OpenStruct.new('id' => '179658', 'uuid' => '7464a789-16a2-482b-a37e-4ffb957be5a4', 'scheme' => 'lgfs', 'scheme_type' => 'Transfer', 'case_number' => 'T20170186', 'state' => 'submitted', 'court_name' => 'Bristol', 'case_type' => 'Transfer', 'total' => '257.81', 'disk_evidence' => false, 'external_user' => 'Stacey Bosco', 'maat_references' => '5696689', 'defendants' => 'Liam Huels', 'fees' => '44.0~Transfer~Fee::TransferFeeType', 'last_submitted_at' => '11/12/2017  10:37:06', 'class_letter' => 'D', 'is_fixed_fee' => false, 'fee_type_code' => '', 'graduated_fee_types' => 'GRTRL,GRRTR,GRGLT,GRDIS,GRRAK,GRCBR', 'allocation_type' => 'Fixed') }
        before { result.merge!(fixed_fee: 1) }
        include_examples 'returns expected JSON filter values'
      end

      context 'when passed a litigator Transfer grad fee' do
        let(:claim) { OpenStruct.new('id' => '179730', 'uuid' => '43016337-ca7a-4ac5-82a2-e32bd8174305', 'scheme' => 'lgfs', 'scheme_type' => 'Transfer', 'case_number' => 'T20177304', 'state' => 'submitted', 'court_name' => 'Croydon', 'case_type' => 'Transfer', 'total' => '333.67', 'disk_evidence' => false, 'external_user' => 'Emmanuelle Olson', 'maat_references' => '5864761', 'defendants' => 'Sadie Keeling', 'fees' => '0.0~Transfer~Fee::TransferFeeType', 'last_submitted_at' => '11/12/2017 10:37:06', 'class_letter' => 'B', 'is_fixed_fee' => false, 'fee_type_code' => '', 'graduated_fee_types' => 'GRTRL,GRRTR,GRGLT,GRDIS,GRRAK,GRCBR', 'allocation_type' => 'Grad') }
        before { result.merge!(graduated_fees: 1) }
        include_examples 'returns expected JSON filter values'
      end

      context 'when passed an advocate claims with an injection attempt error' do
        let(:claim) { OpenStruct.new('id' => '19932', 'uuid' => 'aec3900f-3e82-4c4f-a7cd-498ad45f11f8', 'scheme' => 'agfs', 'scheme_type' => 'Advocate', 'case_number' => 'T20160427', 'state' => 'submitted', 'court_name' => 'Newcastle', 'case_type' => 'Contempt', 'total' => '426.36', 'disk_evidence' => false, 'external_user' => 'Theodore Schumm', 'maat_references' => '2320144', 'defendants' => 'Junius Lesch', 'fees' => '0.0~Daily attendance fee (3 to 40)~Fee::BasicFeeType, 0.0~Daily attendance fee (41 to 50)~Fee::BasicFeeType, 0.0~Daily attendance fee (51+)~Fee::BasicFeeType, 0.0~Standard appearance fee~Fee::BasicFeeType, 0.0~Plea and case management hearing~Fee::BasicFeeType, 0.0~Conferences and views~Fee::BasicFeeType, 0.0~Number of defendants uplift~Fee::BasicFeeType, 0.0~Number of cases uplift~Fee::BasicFeeType, 0.0~Number of prosecution witnesses~Fee::BasicFeeType, 1.0~Basic fee~Fee::BasicFeeType, 34.0~Pages of prosecution evidence~Fee::BasicFeeType', 'last_submitted_at' => '2017-07-06 09:33:30.932017', 'class_letter' => 'F', 'is_fixed_fee' => false, 'fee_type_code' => 'GRRAK', 'graduated_fee_types' => 'GRTRL,GRRTR,GRGLT,GRDIS,GRRAK,GRCBR', 'injection_errors' => '{"errors":[{"error":"Claim not injected"}]}', 'last_injection_succeeded' => 'false') }
        before { result.merge!(graduated_fees: 1, injection_errored: 1) }
        include_examples 'returns expected JSON filter values'
      end

      context 'when passed an advocate claims with a CAV value and without an injection attempt error' do
        let(:claim) { OpenStruct.new('id' => '19932', 'uuid' => 'aec3900f-3e82-4c4f-a7cd-498ad45f11f8', 'scheme' => 'agfs', 'scheme_type' => 'Advocate', 'case_number' => 'T20160427', 'state' => 'submitted', 'court_name' => 'Newcastle', 'case_type' => 'Contempt', 'total' => '426.36', 'disk_evidence' => false, 'external_user' => 'Theodore Schumm', 'maat_references' => '2320144', 'defendants' => 'Junius Lesch', 'fees' => '0.0~Daily attendance fee (3 to 40)~Fee::BasicFeeType, 0.0~Daily attendance fee (41 to 50)~Fee::BasicFeeType, 0.0~Daily attendance fee (51+)~Fee::BasicFeeType, 0.0~Standard appearance fee~Fee::BasicFeeType, 0.0~Plea and case management hearing~Fee::BasicFeeType, 100.0~Conferences and views~Fee::BasicFeeType, 0.0~Number of defendants uplift~Fee::BasicFeeType, 0.0~Number of cases uplift~Fee::BasicFeeType, 0.0~Number of prosecution witnesses~Fee::BasicFeeType, 1.0~Basic fee~Fee::BasicFeeType, 34.0~Pages of prosecution evidence~Fee::BasicFeeType', 'last_submitted_at' => '2017-07-06 09:33:30.932017', 'class_letter' => 'F', 'is_fixed_fee' => false, 'fee_type_code' => 'GRRAK', 'graduated_fee_types' => 'GRTRL,GRRTR,GRGLT,GRDIS,GRRAK,GRCBR', 'injection_errors' => '{"errors":[]}', 'last_injection_succeeded' => 'true') }
        before { result.merge!(graduated_fees: 1, cav_warning: 1) }
        include_examples 'returns expected JSON filter values'
      end

      context 'when passed an advocate claims with CLAR fees and without an injection attempt error' do
        let(:claim) { OpenStruct.new('id' => '19932', 'uuid' => 'aec3900f-3e82-4c4f-a7cd-498ad45f11f8', 'scheme' => 'agfs', 'scheme_type' => 'Advocate', 'case_number' => 'T20200824', 'state' => 'submitted', 'court_name' => 'Newcastle', 'case_type' => 'Contempt', 'total' => '426.36', 'disk_evidence' => false, 'external_user' => 'Theodore Schumm', 'maat_references' => '2320144', 'defendants' => 'Junius Lesch', 'fees' => '0.0~Daily attendance fee (3 to 40)~Fee::BasicFeeType, 0.0~Daily attendance fee (41 to 50)~Fee::BasicFeeType, 0.0~Daily attendance fee (51+)~Fee::BasicFeeType, 0.0~Standard appearance fee~Fee::BasicFeeType, 0.0~Plea and case management hearing~Fee::BasicFeeType, 0.0~Conferences and views~Fee::BasicFeeType, 0.0~Number of defendants uplift~Fee::BasicFeeType, 0.0~Number of cases uplift~Fee::BasicFeeType, 0.0~Number of prosecution witnesses~Fee::BasicFeeType, 1.0~Basic fee~Fee::BasicFeeType, 3.0~Paper heavy case~Fee::MiscFeeType', 'last_submitted_at' => '2020-08-01 09:33:30.932017', 'is_fixed_fee' => false, 'fee_type_code' => 'GRRAK', 'graduated_fee_types' => 'GRTRL,GRRTR,GRGLT,GRDIS,GRRAK,GRCBR', 'injection_errors' => '{"errors":[]}', 'last_injection_succeeded' => 'true') }
        before { result.merge!(graduated_fees: 1, clar_fees_warning: 1) }
        include_examples 'returns expected JSON filter values'
      end

      context 'when passed a litigator claim with CLAR fees and without an injection attempt error' do
        let(:claim) { OpenStruct.new('id' => '19932', 'uuid' => 'aec3900f-3e82-4c4f-a7cd-498ad45f11f8', 'scheme' => 'lgfs', 'scheme_type' => 'Final', 'case_number' => 'T20202401', 'state' => 'submitted', 'court_name' => 'Newcastle', 'case_type' => 'Trial', 'total' => '1200.00', 'disk_evidence' => false, 'external_user' => 'Emile Hirsch', 'maat_references' => '5864761', 'defendants' => 'Junius Leschberg', 'fees' => '1001.0~Trial~Fee::GraduatedFeeType,59.59~Unused materials (upto 3 hours)~Fee::MiscFeeType', 'last_submitted_at' => '2020-04-22T07:27:59Z', 'class_letter' => 'B', 'is_fixed_fee' => false, 'fee_type_code' => 'GRTRL', 'graduated_fee_types' => 'GRTRL,GRRTR,GRGLT,GRDIS,GRRAK,GRCBR', 'allocation_type' => 'Grad', 'injection_errors' => '{"errors":[]}', 'last_injection_succeeded' => 'true') }
        before { result.merge!(trial: 1, graduated_fees: 1, clar_fees_warning: 1) }
        include_examples 'returns expected JSON filter values'
      end

      context 'when passed an advocate interim/warrant claim' do
        let(:claim) { OpenStruct.new('id' => '179818', 'uuid' => '887cbd94-3f48-4955-8646-918de4db3617', 'case_type' => 'Warrant', 'state' => 'submitted', 'total' => '667.33', 'fees' => '0.0~Warrant Fee~Fee::WarrantFeeType', 'last_submitted_at' => '07/12/2017  12:58:29', 'class_letter' => nil, 'is_fixed_fee' => nil, 'fee_type_code' => nil, 'graduated_fee_types' => 'GRTRL,GRRTR,GRGLT,GRDIS,GRRAK,GRCBR') }
        before { result.merge!(agfs_warrants: 1) }
        include_examples 'returns expected JSON filter values'
      end

      context 'when passed an advocate supplementary claim' do
        let(:claim) { OpenStruct.new('id' => '179818', 'uuid' => '887cbd94-3f48-4955-8646-918de4db3617', 'case_type' => 'Supplementary', 'state' => 'submitted', 'total' => '667.33', 'fees' => '0.0~Warrant Fee~Fee::WarrantFeeType', 'last_submitted_at' => '07/12/2017  12:58:29', 'class_letter' => nil, 'is_fixed_fee' => nil, 'fee_type_code' => nil, 'graduated_fee_types' => 'GRTRL,GRRTR,GRGLT,GRDIS,GRRAK,GRCBR') }
        before { result.merge!(supplementary: 1) }
        include_examples 'returns expected JSON filter values'
      end

      context 'when passed an advocate hardship claim' do
        let(:claim) { OpenStruct.new('id' => '19932', 'uuid' => '0635210c-7718-4392-9ebd-995394fd9df4', 'scheme' => 'agfs', 'scheme_type' => 'AdvocateHardship', 'case_number' => 'T20160427', 'state' => 'submitted', 'court_name' => 'Newcastle', 'total' => '426.36', 'disk_evidence' => false, 'external_user' => 'Theodore Schumm', 'maat_references' => '2320144', 'defendants' => 'Junius Lesch', 'fees' => '1.0~Basic fee~Fee::BasicFeeType, 0.0~Standard appearance fee~Fee::BasicFeeType, 0.0~Plea and trial preparation hearing~Fee::BasicFeeType, 0.0~Conferences and views~Fee::BasicFeeType, 0.0~Number of defendants uplift~Fee::BasicFeeType, 0.0~Number of cases uplift~Fee::BasicFeeType, 0.0~Pages of prosecution evidence~Fee::BasicFeeType, 0.0~Daily attendance fee (2+)~Fee::BasicFeeType', 'last_submitted_at' => '2020-04-21 09:33:30.932017', 'is_fixed_fee' => false, 'fee_type_code' => 'GRTRL', 'graduated_fee_types' => 'GRTRL,GRRTR,GRGLT,GRDIS,GRRAK,GRCBR') }

        context 'with a submitted state' do
          before do
            claim.state = 'submitted'
            result.merge!(graduated_fees: 1, agfs_hardship: 1)
          end

          include_examples 'returns expected JSON filter values'
        end

        context 'with a redetermination state' do
          before do
            claim.state = 'redetermination'
            result.merge!(graduated_fees: 0, redetermination: 0, agfs_hardship: 1)
          end

          include_examples 'returns expected JSON filter values'
        end
      end

      context 'when passed a litigator hardship claim' do
        let(:claim) { OpenStruct.new('id' => '179819', 'uuid' => 'a142a3ca-df21-462b-8450-ab97d458a44b', 'scheme' => 'lgfs', 'scheme_type' => 'LitigatorHardship', 'case_number' => 'T20202401', 'state' => 'submitted', 'court_name' => 'Croydon', 'case_type' => 'Trial', 'total' => '1200.00', 'disk_evidence' => false, 'external_user' => 'Emmanuelle Olson', 'maat_references' => '5864761', 'defendants' => 'Sadie Keeling', 'fees' => '1000.0~Hardship~Fee::HardshipFeeType', 'last_submitted_at' => '2020-04-22T07:27:59Z', 'class_letter' => 'B', 'is_fixed_fee' => false, 'fee_type_code' => 'GRTRL', 'graduated_fee_types' => 'GRTRL,GRRTR,GRGLT,GRDIS,GRRAK,GRCBR', 'allocation_type' => 'Grad') }

        context 'with a submitted state' do
          before do
            claim.state = 'submitted'
            result.merge!(graduated_fees: 1, lgfs_hardship: 1, trial: 1)
          end

          include_examples 'returns expected JSON filter values'
        end

        context 'with a redetermination state' do
          before do
            claim.state = 'redetermination'
            result.merge!(redetermination: 0, lgfs_hardship: 1, graduated_fees: 0, trial: 0)
          end

          include_examples 'returns expected JSON filter values'
        end
      end
    end
  end
end
