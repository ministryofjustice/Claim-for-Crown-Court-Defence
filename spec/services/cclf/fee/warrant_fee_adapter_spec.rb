require 'rails_helper'
require 'spec_helper'

RSpec.describe CCLF::Fee::WarrantFeeAdapter, type: :adapter do
  # TODO: § - final claims only, other scenarios exists for transfer claims
  WARRANT_FEE_BILL_SCENARIOS = {
    FXACV: 'ST1TS0T5', # Appeal against conviction
    FXASE: 'ST1TS0T6', # Appeal against sentence
    FXCBR: 'ST3TS3TB', # Breach of Crown Court order
    FXCSE: 'ST1TS0T7', # Committal for Sentence
    FXCON: 'ST1TS0T8', # Contempt
    FXENP: 'ST4TS0T1', # Elected cases not proceeded §
    FXH2S: 'ST1TS0TC', # Hearing subsequent to sentence
    GRDIS: 'ST1TS0T1', # Discontinuance §
    GRGLT: 'ST1TS0T2', # Guilty plea §
    GRTRL: 'ST1TS0T4', # Trial §
    GRRTR: 'ST1TS0TA', # Retrial §
    GRRAK: 'ST1TS0T3', # Cracked trial §
    GRCBR: 'ST1TS0T9', # Cracked before retrial §
  }.freeze

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
    WARRANT_FEE_BILL_SCENARIOS.keys.each do |code|
      context "for #{code} fee type" do
        subject { described_class.new(fee).bill_type }
        include_examples 'returns CCLF Warrant Fee bill type', code
      end
    end
  end

  describe '#bill_subtype' do
    WARRANT_FEE_BILL_SCENARIOS.keys.each do |code|
      context "for #{code} fee type" do
        subject { described_class.new(fee).bill_subtype }
        include_examples 'returns CCLF Warrant Fee bill subtype', code
      end
    end
  end

  describe '#bill_scenario' do
    WARRANT_FEE_BILL_SCENARIOS.each do |code, scenario|
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
