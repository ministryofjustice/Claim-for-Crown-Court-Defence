require 'rails_helper'
require 'spec_helper'

describe API::Entities::SearchResult do
  subject(:search_result) { described_class.represent(claim) }

  describe 'filters' do
    subject(:filter) { JSON.parse(search_result.to_json)['filter'] }

    context 'when passed a submitted case with a graduated fee ' do
      let(:claim) { OpenStruct.new('id'=>'19932', 'uuid'=>'aec3900f-3e82-4c4f-a7cd-498ad45f11f8', 'scheme'=>'agfs', 'scheme_type'=>'Advocate', 'case_number'=>'T20160427', 'state'=>'submitted', 'court_name'=>'Newcastle', 'case_type'=>'Contempt', 'total'=>'426.36', 'disk_evidence'=>'f', 'external_user'=>'Theodore Schumm', 'maat_references'=>'2320144', 'defendants'=>'Junius Lesch', 'fees'=>'0.0~Daily attendance fee (3 to 40)~Fee::BasicFeeType, 0.0~Daily attendance fee (41 to 50)~Fee::BasicFeeType, 0.0~Daily attendance fee (51+)~Fee::BasicFeeType, 0.0~Standard appearance fee~Fee::BasicFeeType, 0.0~Plea and case management hearing~Fee::BasicFeeType, 0.0~Conferences and views~Fee::BasicFeeType, 0.0~Number of defendants uplift~Fee::BasicFeeType, 0.0~Number of cases uplift~Fee::BasicFeeType, 0.0~Number of prosecution witnesses~Fee::BasicFeeType, 1.0~Basic fee~Fee::BasicFeeType, 34.0~Pages of prosecution evidence~Fee::BasicFeeType', 'last_submitted_at'=>'2017-07-06 09:33:30.932017', 'class_letter'=>'F', 'is_fixed_fee'=>'f', 'fee_type_code'=>'GRRAK', 'graduated_fee_types'=>'GRTRL,GRRTR,GRGLT,GRDIS,GRRAK,GRCBR') }
      let(:result) { {'disk_evidence'=>0, 'redetermination'=>0, 'fixed_fee'=>0, 'awaiting_written_reasons'=>0, 'cracked'=>0, 'trial'=>0, 'guilty_plea'=>0, 'graduated_fees'=>1, 'interim_fees'=>0, 'warrants'=>0, 'interim_disbursements'=>0, 'risk_based_bills'=>0} }

      it { is_expected.to eql result }
    end

    context 'when passed a redetermination case with a graduated fee ' do
      let(:claim) { OpenStruct.new('id'=>'19932', 'uuid'=>'aec3900f-3e82-4c4f-a7cd-498ad45f11f8', 'scheme'=>'agfs', 'scheme_type'=>'Advocate', 'case_number'=>'T20160427', 'state'=>'redetermination', 'court_name'=>'Newcastle', 'case_type'=>'Contempt', 'total'=>'426.36', 'disk_evidence'=>'f', 'external_user'=>'Theodore Schumm', 'maat_references'=>'2320144', 'defendants'=>'Junius Lesch', 'fees'=>'0.0~Daily attendance fee (3 to 40)~Fee::BasicFeeType, 0.0~Daily attendance fee (41 to 50)~Fee::BasicFeeType, 0.0~Daily attendance fee (51+)~Fee::BasicFeeType, 0.0~Standard appearance fee~Fee::BasicFeeType, 0.0~Plea and case management hearing~Fee::BasicFeeType, 0.0~Conferences and views~Fee::BasicFeeType, 0.0~Number of defendants uplift~Fee::BasicFeeType, 0.0~Number of cases uplift~Fee::BasicFeeType, 0.0~Number of prosecution witnesses~Fee::BasicFeeType, 1.0~Basic fee~Fee::BasicFeeType, 34.0~Pages of prosecution evidence~Fee::BasicFeeType', 'last_submitted_at'=>'2017-07-06 09:33:30.932017', 'class_letter'=>'F', 'is_fixed_fee'=>'f', 'fee_type_code'=>'GRRAK', 'graduated_fee_types'=>'GRTRL,GRRTR,GRGLT,GRDIS,GRRAK,GRCBR') }
      let(:result) { {'disk_evidence'=>0, 'redetermination'=>1, 'fixed_fee'=>0, 'awaiting_written_reasons'=>0, 'cracked'=>0, 'trial'=>0, 'guilty_plea'=>0, 'graduated_fees'=>0, 'interim_fees'=>0, 'warrants'=>0, 'interim_disbursements'=>0, 'risk_based_bills'=>0} }

      it { is_expected.to eql result }
    end

    context 'when passed a litigator case with a risk based bill' do
      let(:claim) {OpenStruct.new('id'=>'113336', 'uuid'=>'446fd8db-4441-4726-857c-3e80e440f5a2', 'scheme'=>'lgfs', 'scheme_type'=>'Final', 'case_number'=>'T20170329', 'state'=>'submitted', 'court_name'=>'Chester', 'case_type'=>'Guilty plea', 'total'=>'556.11', 'disk_evidence'=>'f', 'external_user'=>'Ozella Adams', 'maat_references'=>'5782148', 'defendants'=>'Vallie King', 'fees'=>'30.0~Guilty plea~Fee::GraduatedFeeType', 'last_submitted_at'=>'2017-07-18 09:19:42.860977', 'class_letter'=>'H', 'is_fixed_fee'=>'f', 'fee_type_code'=>'GRGLT', 'graduated_fee_types'=>'GRTRL,GRRTR,GRGLT,GRDIS,GRRAK,GRCBR') }
      let(:result) { {'disk_evidence'=>0, 'redetermination'=>0, 'fixed_fee'=>0, 'awaiting_written_reasons'=>0, 'cracked'=>0, 'trial'=>0, 'guilty_plea'=>1, 'graduated_fees'=>1, 'interim_fees'=>0, 'warrants'=>0, 'interim_disbursements'=>0, 'risk_based_bills'=>1} }
      it { is_expected.to eql result }
    end

    context 'when passed a litigator case with a final fee' do
      let(:claim) {OpenStruct.new('id'=>'132506', 'uuid'=>'1344fb35-2337-4d22-b45a-5389315d06c5', 'scheme'=>'lgfs', 'scheme_type'=>'Final', 'case_number'=>'S20170495', 'state'=>'redetermination', 'court_name'=>'Newcastle', 'case_type'=>'Committal for Sentence', 'total'=>'309.82', 'disk_evidence'=>'f', 'external_user'=>'Ole Hermann', 'maat_references'=>'5782148', 'defendants'=>'Zetta Rau', 'fees'=>'0.0~Committal for sentence hearings~Fee::FixedFeeType', 'last_submitted_at'=>'2017-07-18 09:19:42.860977', 'class_letter'=>'E', 'is_fixed_fee'=>'t', 'fee_type_code'=>'FXCSE', 'graduated_fee_types'=>'GRTRL,GRRTR,GRGLT,GRDIS,GRRAK,GRCBR') }
      let(:result) { {'disk_evidence'=>0, 'redetermination'=>1, 'fixed_fee'=>0, 'awaiting_written_reasons'=>0, 'cracked'=>0, 'trial'=>0, 'guilty_plea'=>0, 'graduated_fees'=>0, 'interim_fees'=>0, 'warrants'=>0, 'interim_disbursements'=>0, 'risk_based_bills'=>0} }
      it { is_expected.to eql result }
    end

    context 'when passed a litigator case with Final fee' do
      let(:claim) {OpenStruct.new('id' => '180772',	'uuid' => 'ef682b0b-82ef-4908-9b3f-3cee19acc148',	'scheme' => 'lgfs',	'scheme_type' => 'Final',	'case_number' => 'T20170981',	'state' => 'submitted',	'court_name' => 'Newcastle',	'case_type' => 'Elected cases not proceeded',	'total' => '396.4',	'disk_evidence' => 'f',	'external_user' => 'Name Padberg',	'maat_references' => '5924967',	'defendants' => 'Maybell Bahringer',	'fees' => '0.0~Elected case not proceeded~Fee::FixedFeeType',	'last_submitted_at' => '2017-12-08 14:55:58.416695',	'class_letter' => 'H',	'is_fixed_fee' => 't',	'fee_type_code' => 'FXENP',	'graduated_fee_types' => 'GRTRL,GRRTR,GRGLT,GRDIS,GRRAK,GRCBR') }
      let(:result) { {'disk_evidence'=>0, 'redetermination'=>0, 'fixed_fee'=>1, 'awaiting_written_reasons'=>0, 'cracked'=>0, 'trial'=>0, 'guilty_plea'=>0, 'graduated_fees'=>0, 'interim_fees'=>0, 'warrants'=>0, 'interim_disbursements'=>0, 'risk_based_bills'=>0} }
      it { is_expected.to eql result }
    end

    context 'when passed a litigator Disbursement only Interim fee' do
      let(:claim) {OpenStruct.new('id' => '179473',	'uuid' => '7bca9dd7-0a32-442c-b399-85a2379609ad',	'scheme' => 'lgfs',	'scheme_type' => 'Interim',	'case_number' => 'T20170276',	'state' => 'submitted',	'court_name' => 'Worcester',	'case_type' => 'Trial',	'total' => '4652.64',	'disk_evidence' => 'f',	'external_user' => 'Stacey Bosco',	'maat_references' => '5853600',	'defendants' => 'Jordyn Marquardt',	'fees' => '0.0~Disbursement only~Fee::InterimFeeType',	'last_submitted_at' => '07/12/2017  10:30:54',	'class_letter' => 'D',	'is_fixed_fee' => 'f',	'fee_type_code' => 'GRTRL',	'graduated_fee_types' => 'GRTRL,GRRTR,GRGLT,GRDIS,GRRAK,GRCBR') }
      let(:result) { {'disk_evidence'=>0, 'redetermination'=>0, 'fixed_fee'=>0, 'awaiting_written_reasons'=>0, 'cracked'=>0, 'trial'=>1, 'guilty_plea'=>0, 'graduated_fees'=>1, 'interim_fees'=>0, 'warrants'=>0, 'interim_disbursements'=>1, 'risk_based_bills'=>0} }
      it { is_expected.to eql result }
    end

    context 'when passed a litigator warrant Interim fee' do
      let(:claim) {OpenStruct.new('id' => '179818',	'uuid' => '887cbd94-3f48-4955-8646-918de4db3617',	'scheme' => 'lgfs',	'scheme_type' => 'Interim',	'case_number' => 'T20170081',	'state' => 'submitted',	'court_name' => 'Cambridge',	'case_type' => 'Trial',	'total' => '667.33',	'disk_evidence' => 'f',	'external_user' => 'Fernando Zboncak',	'maat_references' => '5663494',	'defendants' => 'Reta Stark',	'fees' => '0.0~Warrant~Fee::InterimFeeType',	'last_submitted_at' => '07/12/2017  12:58:29',	'class_letter' => 'B',	'is_fixed_fee' => 'f',	'fee_type_code' => 'GRTRL',	'graduated_fee_types' => 'GRTRL,GRRTR,GRGLT,GRDIS,GRRAK,GRCBR') }
      let(:result) { {'disk_evidence'=>0, 'redetermination'=>0, 'fixed_fee'=>0, 'awaiting_written_reasons'=>0, 'cracked'=>0, 'trial'=>1, 'guilty_plea'=>0, 'graduated_fees'=>1, 'interim_fees'=>0, 'warrants'=>1, 'interim_disbursements'=>0, 'risk_based_bills'=>0} }
      it { is_expected.to eql result }
    end

    context 'when passed a litigator Interim fee' do
      let(:claim) {OpenStruct.new('id' => '180773',	'uuid' => 'c4a9bf51-ffe1-40eb-8399-f9ae2510b417',	'scheme' => 'lgfs',	'scheme_type' => 'Interim',	'case_number' => 'T20171115',	'state' => 'submitted',	'court_name' => 'Liverpool',	'case_type' => 'Trial',	'total' => '213.3',	'disk_evidence' => 'f',	'external_user' => 'Eldridge Muller',	'maat_references' => '5841779',	'defendants' => 'Destini Thiel',	'fees' => '19.0~Effective PCMH~Fee::InterimFeeType',	'last_submitted_at' => '11/12/2017  10:37:06',	'class_letter' => 'H',	'is_fixed_fee' => 'f',	'fee_type_code' => 'GRTRL',	'graduated_fee_types' => 'GRTRL,GRRTR,GRGLT,GRDIS,GRRAK,GRCBR') }
      let(:result) { {'disk_evidence'=>0, 'redetermination'=>0, 'fixed_fee'=>0, 'awaiting_written_reasons'=>0, 'cracked'=>0, 'trial'=>1, 'guilty_plea'=>0, 'graduated_fees'=>1, 'interim_fees'=>1, 'warrants'=>0, 'interim_disbursements'=>0, 'risk_based_bills'=>0} }
      it { is_expected.to eql result }
    end

    context 'when passed a litigator Transfer fixed fee' do
      let(:claim) {OpenStruct.new('id' => '179658',	'uuid' => '7464a789-16a2-482b-a37e-4ffb957be5a4',	'scheme' => 'lgfs',	'scheme_type' => 'Transfer',	'case_number' => 'T20170186',	'state' => 'submitted',	'court_name' => 'Bristol',	'case_type' => 'Transfer',	'total' => '257.81',	'disk_evidence' => 'f',	'external_user' => 'Stacey Bosco',	'maat_references' => '5696689',	'defendants' => 'Liam Huels',	'fees' => '44.0~Transfer~Fee::TransferFeeType',	'last_submitted_at' => '11/12/2017  10:37:06',	'class_letter' => 'D',	'is_fixed_fee' => 'f',	'fee_type_code' => '',	'graduated_fee_types' => 'GRTRL,GRRTR,GRGLT,GRDIS,GRRAK,GRCBR',	'allocation_type' => 'Fixed') }
      let(:result) { {'disk_evidence'=>0, 'redetermination'=>0, 'fixed_fee'=>1, 'awaiting_written_reasons'=>0, 'cracked'=>0, 'trial'=>0, 'guilty_plea'=>0, 'graduated_fees'=>0, 'interim_fees'=>0, 'warrants'=>0, 'interim_disbursements'=>0, 'risk_based_bills'=>0} }
      it { is_expected.to eql result }
    end

    context 'when passed a litigator Transfer grad fee' do
      let(:claim) {OpenStruct.new('id' => '179730',	'uuid' => '43016337-ca7a-4ac5-82a2-e32bd8174305',	'scheme' => 'lgfs',	'scheme_type' => 'Transfer',	'case_number' => 'T20177304',	'state' => 'submitted',	'court_name' => 'Croydon',	'case_type' => 'Transfer',	'total' => '333.67',	'disk_evidence' => 'f',	'external_user' => 'Emmanuelle Olson',	'maat_references' => '5864761',	'defendants' => 'Sadie Keeling',	'fees' => '0.0~Transfer~Fee::TransferFeeType',	'last_submitted_at' => '11/12/2017 10:37:06',	'class_letter' => 'B',	'is_fixed_fee' => 'f',	'fee_type_code' => '',	'graduated_fee_types' => 'GRTRL,GRRTR,GRGLT,GRDIS,GRRAK,GRCBR',	'allocation_type' => 'Grad') }
      let(:result) { {'disk_evidence'=>0, 'redetermination'=>0, 'fixed_fee'=>0, 'awaiting_written_reasons'=>0, 'cracked'=>0, 'trial'=>0, 'guilty_plea'=>0, 'graduated_fees'=>1, 'interim_fees'=>0, 'warrants'=>0, 'interim_disbursements'=>0, 'risk_based_bills'=>0} }
      it { is_expected.to eql result }
    end
  end
end
