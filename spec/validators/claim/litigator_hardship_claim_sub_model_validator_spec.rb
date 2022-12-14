require 'rails_helper'
require_relative 'shared_examples_for_step_validators'

RSpec.describe Claim::LitigatorHardshipClaimSubModelValidator, type: :validator do
  let(:claim) { create(:litigator_hardship_claim) }

  include_examples 'common partial association validations', {
    has_one: {
      case_details: [],
      defendants: [],
      offence_details: [],
      hardship_fees: [{ name: :hardship_fee }],
      miscellaneous_fees: []
    },
    has_many: {
      case_details: [],
      defendants: [{ name: :defendants, options: { presence: true } }],
      offence_details: [],
      miscellaneous_fees: [{ name: :misc_fees }],
      supporting_evidence: [{ name: :documents }]
    }
  }
end
