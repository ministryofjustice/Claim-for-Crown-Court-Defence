require 'rails_helper'
require_relative 'shared_examples_for_step_validators'

RSpec.describe Claim::InterimClaimSubModelValidator, type: :validator do
  let(:claim) { create(:interim_claim) }

  include_examples 'common partial association validations', {
    has_one: {
      case_details: [],
      defendants: [],
      offence_details: [],
      interim_fees: [{ name: :interim_fee }]
    },
    has_many: {
      case_details: [],
      defendants: [{ name: :defendants, options: { presence: true } }],
      offence_details: [],
      interim_fees: [{ name: :disbursements }],
      travel_expenses: [{ name: :expenses }],
      supporting_evidence: [{ name: :documents }]
    }
  }
end
