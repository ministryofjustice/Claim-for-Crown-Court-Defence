require 'rails_helper'

module Claim
  describe TransferBrainDataItem do

    # let(:item) do
    #   fields = ['original', 'true', 'During trial transfer', 'Guilty plea', 'TRUE', 'Fee full name', 'grad']
    #   TransferBrainDataItem.new(fields)
    # end

    # heh! dont need this ability or test
    # This is testing assigment and the attr_readers, but the attr readers are not needed
    # describe '.new' do
      # it 'instantiates a valid object from an array of strings' do
      #   expect(item.litigator_type).to eq 'original'
      #   expect(item.elected_case).to be true
      #   expect(item.transfer_stage_id).to eq 30
      #   expect(item.case_conclusion_id).to eq 50
      #   expect(item.validity).to be true
      #   expect(item.transfer_fee_full_name).to eq 'Fee full name'
      #   expect(item.allocation_type).to eq 'grad'
      # end
    # end

    # describe 'match_detail?' do
    #   it 'returns true if all fields match' do
    #     detail = transfer_detail('original', true, 30, 50)
    #     expect(item.match_detail?(detail)).to be true
    #   end
    #   it 'returns false if one of the field is different' do
    #     detail = transfer_detail('original', true, 30, 20)
    #     expect(item.match_detail?(detail)).to be false
    #   end

    #   def transfer_detail(lit, ec, tsid, ccid)
    #     build :transfer_detail, litigator_type: lit, elected_case: ec, transfer_stage_id: tsid, case_conclusion_id: ccid
    #   end
    # end

    # not needed
    # context 'invalid initialization array' do
    #   it 'raises' do
    #     expect {
    #       TransferBrainDataItem.new(['xxx', 'xxx'])
    #     }.to raise_error ArgumentError
    #   end
    # end

    describe '#to_h' do
      subject { described_class.new(data_item).to_h }

      let(:data_item) do
        klass = Struct.new(:litigator_type, :elected_case, :transfer_stage, :conclusion, :valid, :transfer_fee_full_name, :allocation_type, :bill_scenario)
        klass.new('NEW','FALSE','Up to and including PCMH transfer','Guilty plea','TRUE','up to and including PCMH transfer (new) - guilty plea','Grad','ST3TS1T2')
      end

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
end
