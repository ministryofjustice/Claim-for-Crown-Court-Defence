require 'rails_helper'
require_relative 'shared_examples_for_advocate_litigator'
require_relative 'shared_examples_for_step_validators'

RSpec.describe Claim::InterimClaimValidator, type: :validator do
  include_context "force-validation"

  let(:litigator) { build(:external_user, :litigator) }
  let(:claim)     { create(:interim_claim) }

  include_examples "common advocate litigator validations", :litigator
  include_examples "common litigator validations"

  include_examples 'common partial validations', [
    %i[
      case_type
      court
      case_number
      case_transferred_from_another_court
      transfer_court
      transfer_case_number
      advocate_category
      case_concluded_at
    ],
    [],
    %i[offence],
    %i[
      first_day_of_trial
      estimated_trial_length
      trial_concluded_at
      retrial_started_at
      retrial_estimated_length
      effective_pcmh_date
      legal_aid_transfer_date
    ],
    %i[total]
  ]

  describe 'estimated trial length and estimated retrial length fields should not accept values of less than 10 days' do
    let(:claim) { create(:interim_claim, interim_fee: interim_fee) }

    before do
      claim.source = 'web'
      claim.form_step = :interim_fees
    end

    context 'estimated_trial_length' do
      let(:interim_fee_type) { build :interim_fee_type, :trial_start }
      let(:interim_fee) { build(:interim_fee, fee_type: interim_fee_type) }

      it 'should error if not present and interim fee type requires it' do
        claim.estimated_trial_length = nil
        should_error_with(claim, :estimated_trial_length, 'blank')
      end

      it 'should error if less than 10 days' do
        claim.estimated_trial_length = 5
        should_error_with(claim, :estimated_trial_length, 'interim_invalid')
      end
    end

    context 'retrial_estimated_length' do
      let(:interim_fee_type) { build :interim_fee_type, :retrial_start }
      let(:interim_fee) { build(:interim_fee, fee_type: interim_fee_type) }

      it 'should error if not present and interim fee type requires it' do
        claim.retrial_estimated_length = nil
        should_error_with(claim, :retrial_estimated_length, 'blank')
      end

      it 'should error if less than 10 days' do
        claim.retrial_estimated_length = 5
        should_error_with(claim, :retrial_estimated_length, 'interim_invalid')
      end
    end
  end
end
