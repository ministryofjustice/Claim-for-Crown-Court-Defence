require 'rails_helper'
require_relative '../validation_helpers'
require_relative 'shared_examples_for_advocate_litigator'
require_relative 'shared_examples_for_step_validators'

describe Claim::InterimClaimValidator do

  include ValidationHelpers
  include_context "force-validation"

  let(:litigator) { build(:external_user, :litigator) }
  let(:claim)     { create(:interim_claim) }

  include_examples "common advocate litigator validations", :litigator
  include_examples "common litigator validations"

  include_examples 'common partial validations', [
      [
          :case_type,
          :court,
          :case_number,
          :advocate_category,
          :offence,
          :case_concluded_at
      ],
      [
          :first_day_of_trial,
          :estimated_trial_length,
          :trial_concluded_at,
          :retrial_started_at,
          :retrial_estimated_length,
          :effective_pcmh_date,
          :legal_aid_transfer_date,
          :total
      ]
  ]
end
