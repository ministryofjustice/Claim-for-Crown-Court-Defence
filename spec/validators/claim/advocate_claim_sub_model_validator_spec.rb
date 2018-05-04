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
      defendants: [{ name: :defendants, options: { presence: true } }],
      offence_details: [],
      basic_fees: [{ name: :basic_fees }],
      fixed_fees: [{ name: :fixed_fees }],
      miscellaneous_fees: [{ name: :misc_fees }],
      travel_expenses: [{ name: :expenses }],
      supporting_evidence: [{ name: :documents }]
    }
  }
end
