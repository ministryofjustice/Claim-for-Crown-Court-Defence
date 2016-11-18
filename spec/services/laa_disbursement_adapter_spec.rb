require 'rails_helper'

describe LaaDisbursementAdapter do

  describe '.laa_bill_type_and_sub_type' do
    context 'existing LAA disbursements' do
      it 'returns the correct laa bill type and sub type' do
        expect(LaaDisbursementAdapter.laa_bill_type_and_sub_type(generate_disbursement('DNA'))).to eq [ 'DISBURSEMENT', 'DNA_TESTING']
        expect(LaaDisbursementAdapter.laa_bill_type_and_sub_type(generate_disbursement('XXX'))).to eq [ 'DISBURSEMENT', 'OTHER']
        expect(LaaDisbursementAdapter.laa_bill_type_and_sub_type(generate_disbursement('VOI'))).to eq [ 'DISBURSEMENT', 'VOICE_RECOG']
      end
    end

    context 'non-existent LAA disbursements' do
      it 'returns nil' do
        expect(LaaDisbursementAdapter.laa_bill_type_and_sub_type(generate_disbursement('CJA'))).to be_nil
        expect(LaaDisbursementAdapter.laa_bill_type_and_sub_type(generate_disbursement('CJP'))).to be_nil
        expect(LaaDisbursementAdapter.laa_bill_type_and_sub_type(generate_disbursement('MCF'))).to be_nil
      end
    end


    def generate_disbursement(code)
      disbursement_type = double DisbursementType, unique_code: code
      double Disbursement, disbursement_type: disbursement_type
    end
  end


end