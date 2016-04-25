require 'rails_helper'
require_relative '../validation_helpers'
require_relative 'shared_examples_for_step_validators'

describe Claim::LitigatorClaimSubModelValidator do

  let(:claim) { FactoryGirl.create :litigator_claim }

  include_examples 'common partial association validations', {
      has_one: [
          [],
          [:graduated_fee, :fixed_fee, :warrant_fee, :assessment, :certification]
      ],
      has_many: [
          [:defendants],
          [:misc_fees, :disbursements, :expenses, :messages, :redeterminations, :documents]
      ]
  }
end
