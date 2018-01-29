require 'rails_helper'
require_relative 'shared_examples_for_step_validators'

RSpec.describe Claim::AdvocateClaimSubModelValidator, type: :validator do
  let(:claim) { FactoryBot.create :claim }

  include_examples 'common partial association validations', {
      has_one: [
          [],
          [],
          [:assessment, :certification]
      ],
      has_many: [
          [],
          [:defendants],
          [:basic_fees, :misc_fees, :fixed_fees, :expenses, :messages, :redeterminations, :documents]
      ]
  }
end
