require 'rails_helper'

module Claim
  describe TransferBrainDataItem do

    let(:item) do
      fields = ['original', 'true', 'During trial transfer', 'Guilty plea', 'TRUE', 'Fee full name', 'grad']
      TransferBrainDataItem.new(fields)
    end

    describe '.new' do
      it 'instantiates a valid object from an array of strings' do
        expect(item.litigator_type).to eq 'original'
        expect(item.elected_case).to be true
        expect(item.transfer_stage_id).to eq 30
        expect(item.case_conclusion_id).to eq 50
        expect(item.validity).to be true
        expect(item.transfer_fee_full_name).to eq 'Fee full name'
        expect(item.allocation_type).to eq 'grad'
      end
    end

    describe 'match_detail?' do
      it 'returns true if all fields match' do
        detail = transfer_detail('original', true, 30, 50)
        expect(item.match_detail?(detail)).to be true
      end
      it 'returns false if one of the field is different' do
        detail = transfer_detail('original', true, 30, 20)
        expect(item.match_detail?(detail)).to be false
      end

      def transfer_detail(lit, ec, tsid, ccid)
        build :transfer_detail, litigator_type: lit, elected_case: ec, transfer_stage_id: tsid, case_conclusion_id: ccid
      end
    end

    describe '#to_h' do
      it 'returns hash' do
        expect(item.to_h).to eq expected_hash
      end

      def expected_hash
        {
          "original" => {
            true => {
              30 => {
                50 => {
                  :validity => true,
                  :transfer_fee_full_name => "Fee full name",
                  :allocation_type => "grad"
                }
              }
            }
          }
        }
      end
    end

  end
end
