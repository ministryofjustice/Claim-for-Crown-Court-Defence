require 'rails_helper'

RSpec.describe Claim::TransferBrainDataItem do
  describe '#to_h' do
    subject { described_class.new(data_item).to_h }

    let(:data_item_klass) { Struct.new(:litigator_type, :elected_case, :transfer_stage, :conclusion, :valid, :transfer_fee_full_name, :allocation_type, :bill_scenario) }
    let(:data_item) { data_item_klass.new('NEW','FALSE','Up to and including PCMH transfer','Guilty plea','TRUE','up to and including PCMH transfer (new) - guilty plea','Grad','ST3TS1T2') }

    it 'returns a hash' do
      is_expected.to be_a(Hash)
    end

    it 'returns expected nested key value pairs' do
      is_expected.to eql expected_hash
    end

    def expected_hash
      {
        "new" => {
          false => {
            10 => {
              50 => {
                :validity => true,
                :transfer_fee_full_name => "up to and including PCMH transfer (new) - guilty plea",
                :allocation_type => "Grad",
                :bill_scenario => "ST3TS1T2"
              }
            }
          }
        }
      }
    end
  end
end
