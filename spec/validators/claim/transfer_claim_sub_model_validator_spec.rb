require 'rails_helper'
require_relative '../validation_helpers'
require_relative 'shared_examples_for_step_validators'

describe Claim::TransferClaimSubModelValidator do

  let(:claim) { FactoryGirl.create :transfer_claim }

  include_examples 'common partial association validations', {
      has_one: [
          [],
          [:transfer_fee, :assessment, :certification]
      ],
      has_many: [
          [:defendants],
          [:disbursements, :messages, :redeterminations, :documents]
      ]
  }
end
