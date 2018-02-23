require 'rails_helper'
require_relative 'shared_examples_for_step_validators'

RSpec.describe Claim::TransferClaimSubModelValidator, type: :validator do
  let(:claim) { FactoryBot.create :transfer_claim }

  include_examples 'common partial association validations', {
    has_one: [
      [],
      [],
      [],
      %i[transfer_fee]
    ],
    has_many: [
      [],
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
