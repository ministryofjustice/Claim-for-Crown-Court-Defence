require 'rails_helper'
require 'spec_helper'

describe API::Entities::CCLF::CaseType do
  subject(:response) { JSON.parse(described_class.represent(claim).to_json).deep_symbolize_keys }
  let(:case_type) { build(:case_type, :trial) }

  context 'for final claims' do
    let(:claim) { instance_double(::Claim::LitigatorClaim, case_type: case_type, interim?: false) }

    it 'has expected json key-value pairs' do
      expect(response).to include(bill_scenario: 'ST1TS0T4')
    end
  end

  context 'for interim claims with an interim fee other than warrant or disbursement only' do
    let(:fee) { build(:interim_fee, :effective_pcmh) }
    let(:claim) { instance_double(::Claim::InterimClaim, case_type: case_type, interim?: true, interim_fee: fee) }

    it 'has expected json key-value pairs' do
      expect(response).to include(bill_scenario: 'ST1TS0T0')
    end
  end
end
