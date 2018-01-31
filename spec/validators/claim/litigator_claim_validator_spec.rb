  require 'rails_helper'
require_relative 'shared_examples_for_advocate_litigator'
require_relative 'shared_examples_for_step_validators'

RSpec.describe Claim::LitigatorClaimValidator, type: :validator do
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
      :case_concluded_at
    ],
    [],
    %i[offence],
    [
      :actual_trial_length,
      :total
    ]
  ]
end
