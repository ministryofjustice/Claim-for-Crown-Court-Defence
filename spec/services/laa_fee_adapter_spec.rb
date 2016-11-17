require 'rails_helper'

describe 'LaaFeeAdapter' do
  context 'AGFS' do

    let(:basic_fee_type) { double Fee::BasicFeeType, unique_code: 'BABAF' }
    let(:basaf_fee_type) { double Fee::BasicFeeType, unique_code: 'BASAF' }
    let(:midth_fee_type) { double Fee::MiscFeeType, unique_code: 'MIDTH' }
    let(:inwar_fee_type) { double Fee::InterimFeeType, unique_code: 'INWAR' }
    let(:fee) { double Fee::BaseFee }
    let(:basic_fee) { double Fee::BasicFee, fee_type: basic_fee_type}

    describe '#laa_bill_type_and_sub_type' do
      context 'basic fees' do

        it 'returns AGFS_APPEAL_CON for basic fee where case type is Appeal against conviction FXACV' do
          fee = generate_basic_fee_with_claim_and_case_type('FXACV')
          expect(LaaFeeAdapter.laa_bill_type_and_sub_type(fee)).to eq ( [ 'AGFS_FEE', 'AGFS_APPEAL_CON'] )
        end

        it 'returns AGFS_APPEAL_SEN for basic fee where case type is Appeal against sentence FXASE' do
          fee = generate_basic_fee_with_claim_and_case_type('FXASE')
          expect(LaaFeeAdapter.laa_bill_type_and_sub_type(fee)).to eq ( [ 'AGFS_FEE', 'AGFS_APPEAL_SEN'] )
        end

        it 'returns AGFS_ORDER_BRCH for basic fee where case type is Breach of Crown Court order FXCBR' do
          fee = generate_basic_fee_with_claim_and_case_type('FXCBR')
          expect(LaaFeeAdapter.laa_bill_type_and_sub_type(fee)).to eq ( [ 'AGFS_FEE', 'AGFS_ORDER_BRCH'] )
        end

        it 'returns AGFS_COMMITTAL for basic fee where case type is Committal for Sentence FXCSE' do
          fee = generate_basic_fee_with_claim_and_case_type('FXCSE')
          expect(LaaFeeAdapter.laa_bill_type_and_sub_type(fee)).to eq ( [ 'AGFS_FEE', 'AGFS_COMMITTAL'] )
        end

        it 'returns nil for basic fee where case type is Contempt FXCON' do
          fee = generate_basic_fee_with_claim_and_case_type('FXCON')
          expect(LaaFeeAdapter.laa_bill_type_and_sub_type(fee)).to be_nil
        end

        it 'returns AGFS_FEE for everything else' do
          %w{ GRRAK  GRCBR GRDIS FXENP GRGLT FXH2S GRRTR GRRTR}.each do |code|
          fee = generate_basic_fee_with_claim_and_case_type(code)
          expect(LaaFeeAdapter.laa_bill_type_and_sub_type(fee)).to eq ( [ 'AGFS_FEE', 'AGFS_FEE'] )
          end
        end

        def generate_basic_fee_with_claim_and_case_type(code)
          case_type = CaseType.create(name: 'xxxx', fee_type_code: code)
          claim = double Claim::AdvocateClaim, case_type: case_type
          fee_type = double Fee::BaseFeeType, unique_code: 'BABAF'
          double(Fee::BasicFee, fee_type: fee_type, claim: claim)
        end
      end


      context 'regular fees with counterparts in LAA system' do
        it 'returns the correct code for BASAF' do
          allow(fee).to receive(:fee_type).and_return(basaf_fee_type)
          expect(LaaFeeAdapter.laa_bill_type_and_sub_type(fee)).to eq ([ 'AGFS_MISC_FEES', 'AGFS_STD_APPRNC'])
        end

        it 'returns the correct code for MIDTH' do
          allow(fee).to receive(:fee_type).and_return(midth_fee_type)
          expect(LaaFeeAdapter.laa_bill_type_and_sub_type(fee)).to eq ([ 'AGFS_MISC_FEES', 'AGFS_CONFISC_HF'])
        end
      end

      context 'regular fees with no counterparts in LAA system' do
        it 'returns nil for INWAR fee type' do
          allow(fee).to receive(:fee_type).and_return(inwar_fee_type)
          expect(LaaFeeAdapter.laa_bill_type_and_sub_type(fee)).to be_nil
        end
      end

    end

  end
end

