require 'rails_helper'
require 'spec_helper'

RSpec.describe CCLF::Fee::WarrantFeeAdapter, type: :adapter do
  # TODO: final claims only, other scenarios exist for transfer claims

  shared_examples 'returns CCLF Warrant Fee bill type' do |code|
    before { allow(fee_type).to receive(:unique_code).and_return code }
    it 'returns CCLF Warrant Fee bill type - FEE_ADVANCE' do
      is_expected.to eql 'FEE_ADVANCE'
    end
  end

  shared_examples 'returns CCLF Warrant Fee bill subtype' do |code|
    before { allow(fee_type).to receive(:unique_code).and_return code }
    it 'returns CCLF Warrant Fee bill type - WARRANT' do
      is_expected.to eql 'WARRANT'
    end
  end

  let(:fee) { instance_double('fee') }
  let(:claim) { instance_double('claim', case_type: case_type) }
  let(:case_type) { instance_double('case_type') }
  let(:fee_type) { instance_double('fee_type', unique_code: 'WARR') }

  before do
    allow(fee).to receive(:fee_type).and_return fee_type
    allow(fee).to receive(:claim).and_return claim
  end

  describe '#bill_type' do
    final_claim_bill_scenarios.keys.each do |code|
      context "for #{code} fee type" do
        subject { described_class.new(fee).bill_type }
        include_examples 'returns CCLF Warrant Fee bill type', code
      end
    end
  end

  describe '#bill_subtype' do
    final_claim_bill_scenarios.keys.each do |code|
      context "for #{code} fee type" do
        subject { described_class.new(fee).bill_subtype }
        include_examples 'returns CCLF Warrant Fee bill subtype', code
      end
    end
  end

  describe '#bill_scenario' do
    final_claim_bill_scenarios.each do |code, scenario|
      context "for #{code} fee type" do
        subject { described_class.new(fee).bill_scenario }

        before do
          allow(case_type).to receive(:fee_type_code).and_return code
        end

        it "returns CCLF Litigator Fee scenario #{scenario}" do
          is_expected.to eql scenario
        end
      end
    end
  end
end
