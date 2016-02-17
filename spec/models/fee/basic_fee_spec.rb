require 'rails_helper'

module Fee
  describe BasicFee do 
    it { should belong_to(:fee_type) }

    it { should validate_presence_of(:claim).with_message('blank')}


    describe '.new_blank' do

      it 'should instantiate but not save a fee with all zero values belonging to the claim and fee type' do
        fee_type = FactoryGirl.build :basic_fee_type
        claim = FactoryGirl.build :claim

        fee = Fee::BasicFee.new_blank(claim, fee_type)
        expect(fee.fee_type).to eq fee_type
        expect(fee.claim).to eq claim
        expect(fee.quantity).to eq 0
        expect(fee.amount).to eq 0
        expect(fee).to be_new_record
      end

      # TODO: BAF fee type used to be instatiated to 1 but has been removed - POCA ticket - can remove eventually
      context 'for the BAF basic fee' do
        it 'should be called as part of claim instatiation and assign 0 as quantity for BAF fee types' do
          baf_fee_type = FactoryGirl.create :basic_fee_type, code: 'BAF'
          claim = FactoryGirl.build :claim
          fee = claim.basic_fees.first
          expect(fee.fee_type.code).to eql 'BAF'
          expect(fee.amount).to eq 0.00
          expect(fee.quantity).to eq 0
          expect(fee).to be_new_record
        end
      end
    end

    describe '#calculated?' do
      it 'should return false for fees flagged as uncalculated' do
        ppe = FactoryGirl.create(:basic_fee_type, code: 'PPE', calculated: false)
        fee = FactoryGirl.create(:basic_fee, fee_type: ppe)
        expect(fee.calculated?).to be false
      end
      it 'should return true for any other fees' do
        saf = FactoryGirl.create(:basic_fee_type,  code: 'SAF')
        fee = FactoryGirl.create(:basic_fee, fee_type: saf)
        expect(fee.calculated?).to be true
      end
    end
  end
end