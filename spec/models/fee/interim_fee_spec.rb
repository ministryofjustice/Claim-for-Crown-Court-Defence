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
#  date                  :date
#

require 'rails_helper'
require_relative 'shared_examples_for_duplicable'

RSpec.describe Fee::InterimFee do
  let(:fee)               { build(:interim_fee) }
  let(:disbursement_fee)  { build(:interim_fee, fee_type: build(:interim_fee_type, :disbursement_only)) }
  let(:warrant_fee)       { build(:interim_fee, fee_type: build(:interim_fee_type, :warrant)) }
  let(:pcmh_fee)          { build(:interim_fee, fee_type: build(:interim_fee_type, :effective_pcmh)) }
  let(:trial_start_fee)   { build(:interim_fee, fee_type: build(:interim_fee_type, :trial_start)) }
  let(:retrial_start_fee) { build(:interim_fee, fee_type: build(:interim_fee_type, :retrial_start)) }
  let(:retrial_new_solicitor_fee) { build(:interim_fee, fee_type: build(:interim_fee_type, :retrial_new_solicitor)) }

  include_examples 'duplicable fee'

  describe '#is_interim?' do
    it 'is true' do
      expect(fee.is_interim?).to be true
    end
  end

  describe '#is_disbursement?' do
    it 'is true for disbursements' do
      expect(disbursement_fee.is_disbursement?).to be true
    end

    it 'is false for other fees' do
      expect(warrant_fee.is_disbursement?).to be false
    end
  end

  describe '#is_interim_warrant?' do
    it 'is false for other fees' do
      expect(disbursement_fee.is_interim_warrant?).to be false
    end

    it 'is true for warrant_fees' do
      expect(warrant_fee.is_interim_warrant?).to be true
    end
  end

  describe '#is_effective_pcmh?' do
    it 'is false for other fees' do
      expect(warrant_fee.is_effective_pcmh?).to be false
    end

    it 'is true for Effective PCMH fees' do
      expect(pcmh_fee.is_effective_pcmh?).to be true
    end
  end

  describe '#is_trial_start?' do
    it 'is false for other fees' do
      expect(warrant_fee.is_trial_start?).to be false
    end

    it 'is true for Trial start fees' do
      expect(trial_start_fee.is_trial_start?).to be true
    end
  end

  describe '#is_retrial_start?' do
    it 'is false for other fees' do
      expect(warrant_fee.is_retrial_start?).to be false
    end

    it 'is true for Retrial start fees' do
      expect(retrial_start_fee.is_retrial_start?).to be true
    end
  end

  describe '#is_retrial_new_solicitor?' do
    it 'is false for other fees' do
      expect(warrant_fee.is_retrial_new_solicitor?).to be false
    end

    it 'is true for Retrial New solicitor fees' do
      expect(retrial_new_solicitor_fee.is_retrial_new_solicitor?).to be true
    end
  end

  describe '#perform_validation?' do
    let(:claim) { fee.claim }

    subject { fee.perform_validation? }

    before do
      allow(claim).to receive(:perform_validation?).and_return(false)
      allow(fee).to receive(:validation_required?).and_return(false)
    end

    specify { is_expected.to be_falsey }

    context 'when the associated claim needs validation' do
      before do
        allow(claim).to receive(:perform_validation?).and_return(true)
      end

      context 'and the fee also needs validation' do
        before do
          allow(fee).to receive(:validation_required?).and_return(true)
        end

        specify { is_expected.to be_truthy }
      end

      context 'and the fee does not require validation' do
        before do
          allow(fee).to receive(:validation_required?).and_return(false)
        end

        specify { is_expected.to be_falsey }
      end
    end
  end

  describe '#validation_required?' do
    let(:claim) { fee.claim }
    let(:step) { :interim_fees }

    subject { fee.validation_required? }

    before do
      allow(claim).to receive(:from_api?).and_return(false)
      allow(claim).to receive(:step_in_steps_range?).with(step).and_return(false)
    end

    specify { is_expected.to be_falsey }

    context 'when the claim submission source is the API' do
      before do
        allow(claim).to receive(:from_api?).and_return(true)
      end

      specify { is_expected.to be_truthy }
    end

    context 'when the submission stage requires the fee to be validated' do
      before do
        allow(claim).to receive(:step_in_steps_range?).with(step).and_return(true)
      end

      specify { is_expected.to be_truthy }
    end
  end
end
