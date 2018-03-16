require 'rails_helper'
require_relative 'shared_examples_for_step_validators'

RSpec.describe Claim::LitigatorClaimSubModelValidator, type: :validator do
  let(:claim) { FactoryBot.create :litigator_claim }

  include_examples 'common partial association validations', {
    has_one: [
      [],
      [],
      [],
      %i[fixed_fee],
      %i[graduated_fee]
    ],
    has_many: [
      [],
      %i[defendants],
      [],
      %i[misc_fees],
      %i[disbursements],
      %i[expenses],
      %i[documents]
    ]
  }
end
