require 'rails_helper'

RSpec.describe CCLF::Fee::InterimFeeAdapter, type: :adapter do
   INTERIM_FEE_BILL_TYPES = {
    INPCM: ['LIT_FEE', 'LIT_FEE'], # Effective PCMH
    INRNS: ['LIT_FEE', 'LIT_FEE'], # Retrial New solicitor
    INRST: ['LIT_FEE', 'LIT_FEE'], # Retrial start
    INTDT: ['LIT_FEE', 'LIT_FEE'], # Trial start
    INWAR: ['FEE_ADVANCE', 'WARRANT'] # Warrant
  }.freeze

  context 'bill mappings' do
    INTERIM_FEE_BILL_TYPES.each do |unique_code, bill_types|
      context "when an interim fee of type #{unique_code} exists" do
        subject(:instance) { described_class.new(fee) }
        let(:claim) { instance_double(::Claim::InterimClaim) }
        let(:fee_type) { instance_double(::Fee::InterimFeeType, unique_code: unique_code) }
        let(:fee) { instance_double(::Fee::InterimFee, fee_type: fee_type, claim: claim) }

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
