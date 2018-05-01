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
      transfer_fees: %i[transfer_fee]
    },
    has_many: {
      transfer_fee_details: [],
      case_details: [],
      defendants: %i[defendants],
      offence_details: [],
      miscellaneous_fees: %i[misc_fees],
      disbursements: %i[disbursements],
      travel_expenses: %i[expenses],
      supporting_evidence: %i[documents]
    }
  }
end
