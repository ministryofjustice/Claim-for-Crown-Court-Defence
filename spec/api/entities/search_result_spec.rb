require 'rails_helper'
require 'spec_helper'

describe API::Entities::SearchResult do
  subject(:search_result) { described_class.represent(claim) }

  describe 'filters' do
    subject(:filter) { JSON.parse(search_result.to_json)['filter'] }

    context 'when passed a redetermination case' do
      let(:claim) { create(:deterministic_claim, :redetermination) }

      let(:result) { {'redetermination'=>true, 'fixed_fee'=>true, 'awaiting_written_reasons'=>false, 'cracked'=>false, 'trial'=>false, 'guilty_plea'=>false, 'graduated_fees'=>false, 'interim_fees'=>false, 'warrants'=>false, 'interim_disbursements'=>false, 'risk_based_bills'=>false} }

      it { is_expected.to eql result }
    end

    context 'when passed a litigator case with a risk based bill' do
      let!(:claim) { create(:litigator_claim, :risk_based_bill) }

      let(:result) { {'redetermination'=>false, 'fixed_fee'=>false, 'awaiting_written_reasons'=>false, 'cracked'=>false, 'trial'=>false, 'guilty_plea'=>false, 'graduated_fees'=>false, 'interim_fees'=>false, 'warrants'=>false, 'interim_disbursements'=>false, 'risk_based_bills'=>true} }

      it { is_expected.to eql result }
    end

    context 'when passed a litigator case with a graduated fee bill' do
      let(:claim) { create(:litigator_claim, :graduated_fee) }
      let(:result) { {'redetermination'=>false, 'fixed_fee'=>false, 'awaiting_written_reasons'=>false, 'cracked'=>false, 'trial'=>false, 'guilty_plea'=>false, 'graduated_fees'=>true, 'interim_fees'=>false, 'warrants'=>false, 'interim_disbursements'=>false, 'risk_based_bills'=>false} }

      before { claim.submit! }

      it { is_expected.to eql result }
    end
  end
end
