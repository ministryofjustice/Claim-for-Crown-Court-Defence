require 'rails_helper'
require_relative '../validation_helpers'
require_relative 'shared_examples_for_step_validators'

describe Claim::InterimClaimSubModelValidator do

  let(:claim) { FactoryBot.create :interim_claim }

  include_examples 'common partial association validations', {
      has_one: [
          [],
          [:interim_fee, :assessment, :certification]
      ],
      has_many: [
          [:defendants],
          [:disbursements, :messages, :redeterminations, :documents]
      ]
  }
end
