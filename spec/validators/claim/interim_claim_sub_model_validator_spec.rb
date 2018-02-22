require 'rails_helper'
require_relative 'shared_examples_for_step_validators'

RSpec.describe Claim::InterimClaimSubModelValidator, type: :validator do
  let(:claim) { create(:interim_claim) }

  include_examples 'common partial association validations', {
    has_one: [
      [],
      [],
      [],
      %i[interim_fee]
    ],
    has_many: [
      [],
      %i[defendants],
      [],
      %i[disbursements],
      %i[expenses],
      %i[documents]
    ]
  }
end
