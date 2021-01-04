require 'rails_helper'
require_relative 'shared_examples_for_step_validators'

RSpec.describe Claim::AdvocateSupplementaryClaimSubModelValidator, type: :validator do
  let(:claim) { create(:advocate_supplementary_claim) }

  include_examples 'common partial association validations', {
    has_one: {
      case_details: [],
      defendants: []
    },
    has_many: {
      case_details: [],
      defendants: [{ name: :defendants, options: { presence: true } }],
      miscellaneous_fees: [{ name: :misc_fees, options: { presence: true } }],
      travel_expenses: [{ name: :expenses }],
      supporting_evidence: [{ name: :documents }]
    }
  }
end
