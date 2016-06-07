require 'rails_helper'
require_relative '../validation_helpers'
require_relative 'shared_examples_for_step_validators'

describe Claim::AdvocateClaimSubModelValidator do
  let(:claim) { FactoryGirl.create :claim }

  include_examples 'common partial association validations', {
      has_one: [
          [],
          [:assessment, :certification]
      ],
      has_many: [
          [:defendants],
          [:basic_fees, :misc_fees, :fixed_fees, :expenses, :messages, :redeterminations, :documents]
      ]
  }
end
