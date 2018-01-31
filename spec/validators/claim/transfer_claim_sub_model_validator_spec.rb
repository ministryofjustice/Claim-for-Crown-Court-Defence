require 'rails_helper'
require_relative 'shared_examples_for_step_validators'

RSpec.describe Claim::TransferClaimSubModelValidator, type: :validator do
  let(:claim) { FactoryBot.create :transfer_claim }

  include_examples 'common partial association validations', {
      has_one: [
                  [ ],
                  [
                    :transfer_fee,
                    :assessment,
                    :certification
                  ]
               ],
      has_many: [
                  [],
                  [
                    :defendants,
                  ],
                  [
                    :misc_fees,
                    :disbursements,
                    :expenses,
                    :messages,
                    :redeterminations,
                    :documents
                  ]
                ]

  }
end
