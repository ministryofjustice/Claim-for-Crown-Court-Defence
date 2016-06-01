# == Schema Information
#
# Table name: fees
#
#  id                    :integer          not null, primary key
#  claim_id              :integer
#  fee_type_id           :integer
#  quantity              :decimal(, )
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
    let(:pcmh_fee)          { build :interim_fee, fee_type: build(:interim_fee_type, :effective_pcmh) }
    let(:trial_start_fee)   { build :interim_fee, fee_type: build(:interim_fee_type, :trial_start) }
    let(:retrial_start_fee) { build :interim_fee, fee_type: build(:interim_fee_type, :retrial_start) }
    let(:retrial_new_solicitor_fee) { build :interim_fee, fee_type: build(:interim_fee_type, :retrial_new_solicitor) }

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

    describe '#is_interim_warrant?' do
      it 'should be false for other fees' do
        expect(disbursement_fee.is_interim_warrant?).to be false
      end

      it 'should be true for warrant_fees' do
        expect(warrant_fee.is_interim_warrant?).to be true
      end
    end

    describe '#is_effective_pcmh?' do
      it 'should be false for other fees' do
        expect(warrant_fee.is_effective_pcmh?).to be false
      end

      it 'should be true for Effective PCMH fees' do
        expect(pcmh_fee.is_effective_pcmh?).to be true
      end
    end

    describe '#is_trial_start?' do
      it 'should be false for other fees' do
        expect(warrant_fee.is_trial_start?).to be false
      end

      it 'should be true for Trial start fees' do
        expect(trial_start_fee.is_trial_start?).to be true
      end
    end

    describe '#is_retrial_start?' do
      it 'should be false for other fees' do
        expect(warrant_fee.is_retrial_start?).to be false
      end

      it 'should be true for Retrial start fees' do
        expect(retrial_start_fee.is_retrial_start?).to be true
      end
    end

    describe '#is_retrial_start?' do
      it 'should be false for other fees' do
        expect(warrant_fee.is_retrial_new_solicitor?).to be false
      end

      it 'should be true for Retrial New solicitor fees' do
        expect(retrial_new_solicitor_fee.is_retrial_new_solicitor?).to be true
      end
    end
  end
end
