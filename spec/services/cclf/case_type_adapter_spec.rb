require 'rails_helper'

RSpec.describe CCLF::CaseTypeAdapter, type: :adapter do
  subject { described_class.new(claim).bill_scenario }
  let(:case_type) { instance_double(::CaseType) }

  include TransferBrainHelpers

  before do
    allow(claim).to receive(:interim?).and_return false
    allow(claim).to receive(:transfer?).and_return false
  end

  describe '#bill_scenario' do
    context 'final claim' do
      let(:claim) { instance_double(::Claim::LitigatorClaim, case_type: case_type) }

      final_claim_bill_scenarios.each do |code, scenario|
        context "maps #{code} to #{scenario}" do
          before do
            allow(case_type).to receive(:fee_type_code).and_return code
          end

          it "returns #{scenario}" do
            is_expected.to eql scenario
          end
        end
      end
    end

    context 'interim claim' do
      let(:claim) { instance_double(::Claim::InterimClaim, interim?: true, case_type: case_type) }

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
              allow(claim).to receive(:interim?).and_return true
              allow(claim).to receive(:interim_fee).and_return fee
              allow(case_type).to receive(:fee_type_code).and_return code
            end

            it "returns #{scenario}" do
              is_expected.to eql scenario
            end
          end
        end
      end
    end

    context 'transfer claim' do
      let(:claim) { instance_double(::Claim::TransferClaim) }
      let(:transfer_detail) { instance_double(::Claim::TransferDetail, bill_scenario: bill_scenario) }

      transfer_fee_bill_scenarios.each do |scenario|
        context "having transfer detail with scenario #{scenario}" do
          let(:bill_scenario) { scenario }

          before do
            allow(claim).to receive(:transfer?).and_return true
            allow(claim).to receive(:transfer_detail).and_return transfer_detail
          end

          it "returns #{scenario}" do
            is_expected.to eql scenario
          end
        end
      end
    end
  end
end
