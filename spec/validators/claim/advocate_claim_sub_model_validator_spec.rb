require 'rails_helper'
require_relative 'shared_examples_for_step_validators'

RSpec.describe Claim::AdvocateClaimSubModelValidator, type: :validator do
  let(:claim) { FactoryBot.create :claim }

  include_examples 'common partial association validations', {
      has_one: [
          [],
          []
      ],
      has_many: [
          [],
          %i[defendants],
          %i[basic_fees fixed_fees],
          %i[misc_fees],
          %i[expenses],
          %i[documents],
          []
      ]
  }
end
