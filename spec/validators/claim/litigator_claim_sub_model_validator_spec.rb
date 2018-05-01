require 'rails_helper'
require_relative 'shared_examples_for_step_validators'

RSpec.describe Claim::LitigatorClaimSubModelValidator, type: :validator do
  let(:claim) { FactoryBot.create :litigator_claim }

  include_examples 'common partial association validations', {
    has_one: {
      case_details: [],
      defendants: [],
      offence_details: [],
      fixed_fees: %i[fixed_fee],
      graduated_fees: %i[graduated_fee]
    },
    has_many: {
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
