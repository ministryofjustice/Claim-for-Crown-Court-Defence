require 'rails_helper'

RSpec.describe CCLF::Fee::WarrantFeeAdapter, type: :adapter do
  let(:fee) { instance_double('fee') }
  let(:claim) { instance_double('claim', case_type: case_type) }
  let(:case_type) { instance_double('case_type') }
  let(:fee_type) { instance_double('fee_type', unique_code: 'WARR') }

  before do
    allow(fee).to receive(:fee_type).and_return fee_type
    allow(fee).to receive(:claim).and_return claim
  end

  describe '#bill_type' do
    subject { described_class.new(fee).bill_type }
    it 'returns CCLF Warrant Fee bill type - FEE_ADVANCE' do
      is_expected.to eql 'FEE_ADVANCE'
    end
  end

  describe '#bill_subtype' do
    subject { described_class.new(fee).bill_subtype }
    it 'returns CCLF Warrant Fee bill subtype - WARRANT' do
      is_expected.to eql 'WARRANT'
    end
  end
end
