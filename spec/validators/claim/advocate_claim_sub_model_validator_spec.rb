require 'rails_helper'
require_relative 'shared_examples_for_step_validators'

RSpec.describe Claim::AdvocateClaimSubModelValidator, type: :validator do
  let(:claim) { FactoryBot.create :claim }

  include_examples 'common partial association validations', {
    has_one: {
      case_details: [],
      defendants: [],
      offence_details: []
    },
    has_many: {
      case_details: [],
      defendants: %i[defendants],
      offence_details: [],
      basic_and_fixed_fees: %i[basic_fees fixed_fees],
      miscellaneous_fees: %i[misc_fees],
      travel_expenses: %i[expenses],
      supporting_evidence: %i[documents]
    }
  }
end
