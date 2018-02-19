require 'rails_helper'

RSpec.describe CCLF::CaseTypeAdapter, type: :adapter do
  subject { described_class.new(claim).bill_scenario }

  let(:case_type) { instance_double(::CaseType) }
  let(:claim) { instance_double(::Claim::InterimClaim, case_type: case_type) }

  describe '#bill_scenario' do
    context 'final claim' do
      final_claim_bill_scenarios.each do |code, scenario|
        context "maps #{code} to #{scenario}" do
          before do
            allow(claim).to receive(:interim_fee).and_return nil
            allow(claim).to receive(:interim?).and_return false
            allow(case_type).to receive(:fee_type_code).and_return code
          end

          it "returns #{scenario}" do
            is_expected.to eql scenario
          end
        end
      end
    end

    context 'interim claim' do
      context 'with interim fee types other than warrants' do
        interim_fee_bill_scenarios.each do |code, scenario|
          context "maps #{code} to #{scenario}" do
            let(:fee_type) { instance_double(::Fee::InterimFeeType, unique_code: code) }
            let(:fee) { instance_double(::Fee::InterimFee, fee_type: fee_type, is_interim_warrant?: false) }

            before do
              allow(claim).to receive(:interim_fee).and_return fee
              allow(claim).to receive(:interim?).and_return true
            end

            it "returns #{scenario}" do
              is_expected.to eql scenario
            end
          end
        end
      end

      context 'with an interim warrant fee type' do
        final_claim_bill_scenarios.each do |code, scenario|
          context "maps #{code} to #{scenario}" do
            let(:fee_type) { instance_double(::Fee::InterimFeeType, unique_code: 'INWAR') }
            let(:fee) { instance_double(::Fee::InterimFee, fee_type: fee_type, is_interim_warrant?: true) }

            before do
              allow(claim).to receive(:interim_fee).and_return fee
              allow(claim).to receive(:interim?).and_return true
              allow(case_type).to receive(:fee_type_code).and_return code
            end

            it "returns #{scenario}" do
              is_expected.to eql scenario
            end
          end
        end
      end
    end
  end
end
