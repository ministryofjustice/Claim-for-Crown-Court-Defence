require 'rails_helper'
require 'spec_helper'

module CCLF
  module Fee
    describe FixedFeeAdapter do
      subject { described_class.new.call(fee) }
      let(:claim) { instance_double('claim') }
      let(:fee) { instance_double('fee') }
      let(:fee_type) { instance_double('fee_type', unique_code: 'FXACV') }

      before do
        allow(fee).to receive(:fee_type).and_return fee_type
      end

      BILL_SCENARIO_MAPPINGS = {
        FXACV: 'ST1TS0T5', # Appeal against conviction
        FXASE: 'ST1TS0T6', # Appeal against sentence
        FXCBR: 'ST3TS3TB', # Breach of Crown Court order
        FXCSE: 'ST1TS0T7', # Committal for Sentence
        FXCON: 'ST1TS0T8', # Contempt
        FXENP: 'ST4TS0T1', # Elected cases not proceeded
        FXH2S: 'ST1TS0TC', # Hearing subsequent to sentence
      }.freeze

      shared_examples 'returns CCLF Litigator Fee bill type' do |code|
        before { allow(fee_type).to receive(:unique_code).and_return code }
        it 'returns expected JSON filterable values' do
          is_expected.to eql 'LIT_FEE'
        end
      end

      describe '#bill_type' do
        BILL_SCENARIO_MAPPINGS.keys.each do |code|
          context "for #{code} fee type" do
            subject { described_class.new(fee).bill_type }
            include_examples 'returns CCLF Litigator Fee bill type', code
          end
        end
      end

      describe '#bill_subtype' do
        BILL_SCENARIO_MAPPINGS.keys.each do |code|
          context "for #{code} fee type" do
            subject { described_class.new(fee).bill_subtype }
            include_examples 'returns CCLF Litigator Fee bill type', code
          end
        end
      end

      describe '#bill_scenario' do
        BILL_SCENARIO_MAPPINGS.each do |code, scenario|
          context "for #{code} fee type" do
            subject { described_class.new(fee).bill_scenario }

            before { allow(fee_type).to receive(:unique_code).and_return code }

            it "returns CCLF Litigator Fee scenario #{scenario}" do
              is_expected.to eql scenario
            end
          end
        end
      end

      describe '#claimed?' do
        subject { described_class.new(fee).claimed? }

        context 'when fixed fee amount is positive' do
          let(:fee) { instance_double('fee', amount: 0.01) }
          it 'returns true' do
            is_expected.to eql true
          end
        end

        context 'when fixed fee amount is nil' do
          let(:fee) { instance_double('fee', amount: nil) }
          it 'returns false' do
            is_expected.to eql false
          end
        end

        context 'when fixed fee amount is 0' do
          let(:fee) { instance_double('fee', amount: nil) }
          it 'returns false' do
            is_expected.to eql false
          end
        end
      end
    end
  end
end
