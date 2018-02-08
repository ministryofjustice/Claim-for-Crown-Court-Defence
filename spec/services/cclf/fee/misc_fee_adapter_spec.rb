require 'rails_helper'
require 'spec_helper'

RSpec.describe CCLF::Fee::MiscFeeAdapter, type: :adapter do
  let(:fee) { instance_double(::Fee::MiscFee) }

  # For a given misc fee type the misc fee maps to a given CCLF bill type and sub type
  # however the bill scenario and "formula"* depend on the
  # case type and litigator claim type.
  # *nb: formula is used CCLF-side only and maps to whether to use quantity or amount???
  #
  MISC_FEE_BILL_TYPES = {
    # MIUPL: [nil, nil], # Case uplift - no equivalent in LGFS - to be removed from app too?!
    MICJA: ['OTHER', 'COST_JUDGE_FEE'], # Costs judge application
    MICJP: ['OTHER', 'COST_JUD_EXP'], # Costs judge preparation
    MIEVI: ['EVID_PROV_FEE', 'EVID_PROV_FEE'], # Evidence provision fee
    MISPF: ['FEE_SUPPLEMENT', 'SPECIAL_PREP'] # Special preparation fee
  }.freeze

  context 'bill mappings' do
    MISC_FEE_BILL_TYPES.each do |unique_code, bill_types|
      final_claim_bill_scenarios.each do |fee_type_code, scenario|
        context "when a misc fee of type #{unique_code} is attached to a claim with case of type #{fee_type_code}" do
          subject(:instance) { described_class.new(fee) }
          let(:claim) { instance_double(::Claim::LitigatorClaim, case_type: case_type) }
          let(:case_type) { instance_double(::CaseType, fee_type_code: fee_type_code) }
          let(:fee_type) { instance_double(::Fee::MiscFeeType, unique_code: unique_code) }

          before do
            allow(fee).to receive(:claim).and_return claim
            allow(fee).to receive(:fee_type).and_return fee_type
          end

          describe '#bill_type' do
            subject { instance.bill_type }
            it "returns #{bill_types.first}" do
              is_expected.to eql bill_types.first
            end
          end

          describe '#bill_subtype' do
            subject { instance.bill_subtype }
            it "returns #{bill_types.second}" do
              is_expected.to eql bill_types.second
            end
          end
        end
      end
    end
  end
end
