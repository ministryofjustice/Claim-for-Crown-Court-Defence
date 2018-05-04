require 'rails_helper'
require_relative 'shared_examples_for_step_validators'

RSpec.describe Claim::TransferClaimSubModelValidator, type: :validator do
  let(:claim) { FactoryBot.create :transfer_claim }

  include_examples 'common partial association validations', {
    has_one: {
      transfer_fee_details: [],
      case_details: [],
      defendants: [],
      offence_details: [],
      transfer_fees: [{ name: :transfer_fee, options: { presence: true } }]
    },
    has_many: {
      transfer_fee_details: [],
      case_details: [],
      defendants: [{ name: :defendants, options: { presence: true } }],
      offence_details: [],
      miscellaneous_fees: [{ name: :misc_fees }],
      disbursements: [{ name: :disbursements }],
      travel_expenses: [{ name: :expenses }],
      supporting_evidence: [{ name: :documents }]
    }
  }
end
