require 'rails_helper'
require_relative 'shared_examples_for_step_validators'

RSpec.describe Claim::LitigatorClaimSubModelValidator, type: :validator do
  let(:claim) { FactoryBot.create :litigator_claim }

  include_examples 'common partial association validations', {
    has_one: {
      case_details: [],
      defendants: [],
      offence_details: [],
      fixed_fees: [{ name: :fixed_fee }],
      graduated_fees: [{ name: :graduated_fee }],
      miscellaneous_fees: [{ name: :interim_claim_info }]
    },
    has_many: {
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
