  require 'rails_helper'
require_relative '../validation_helpers'
require_relative 'shared_examples_for_advocate_litigator'
require_relative 'shared_examples_for_step_validators'

describe Claim::LitigatorClaimValidator do

  include ValidationHelpers
  include_context "force-validation"

  let(:litigator) { build(:external_user, :litigator) }
  let(:claim)     { create(:litigator_claim) }

  include_examples "common advocate litigator validations", :litigator
  include_examples "common litigator validations"

  include_examples 'common partial validations', [
      [
          :case_type,
          :court,
          :case_number,
          :transfer_court,
          :transfer_case_number,
          :advocate_category,
          :offence,
          :case_concluded_at
      ],
      [
          :actual_trial_length,
          :total
      ]
  ]
end
