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
  end
end
