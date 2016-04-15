# == Schema Information
#
# Table name: fees
#
#  id                    :integer          not null, primary key
#  claim_id              :integer
#  fee_type_id           :integer
#  quantity              :integer
#  amount                :decimal(, )
#  created_at            :datetime
#  updated_at            :datetime
#  uuid                  :uuid
#  rate                  :decimal(, )
#  type                  :string
#  warrant_issued_date   :date
#  warrant_executed_date :date
#  sub_type_id           :integer
#  case_numbers          :string
#

require 'rails_helper'

module Fee
  describe InterimFee do

    let(:fee)               { build :interim_fee }
    let(:disbursement_fee)  { build :interim_fee, fee_type: build(:interim_fee_type, :disbursement) }
    let(:warrant_fee)       { build :interim_fee, fee_type: build(:interim_fee_type, :warrant) }

    describe '#is_interim?' do
      it 'should be true' do
        expect(fee.is_interim?).to be true
      end
    end

    describe '#is_disbursemen?t' do
      it 'should be true for disbursements' do
        expect(disbursement_fee.is_disbursement?).to be true
      end

      it 'should be false for other fees' do
        expect(warrant_fee.is_disbursement?).to be false
      end
    end

    describe '#is_warrant?' do
      it 'should be false for other fees' do
        expect(disbursement_fee.is_warrant?).to be false
      end

      it 'should be true for warrant_fees' do
        expect(warrant_fee.is_warrant?).to be true
      end
    end
  end
end
