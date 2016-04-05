require 'rails_helper'
require_relative '../validation_helpers'
require_relative 'shared_examples_for_advocate_litigator'

describe Claim::AdvocateClaimValidator do

  include ValidationHelpers
  include_context "force-validation"

  let(:litigator)     { create(:external_user, :litigator) }
  let(:claim)         { create :advocate_claim }

  include_examples "common advocate litigator validations", :advocate

  context 'case concluded at date' do
    let(:claim)    { build :claim }

    it 'is valid when absent' do
      expect(claim.case_concluded_at).to be_nil
      claim.valid?
      expect(claim.errors.key?(:case_concluded_at)).to be false
    end

    it 'is invalid when present' do
      claim.case_concluded_at = 1.month.ago
      expect(claim).not_to be_valid
      expect(claim.errors[:case_concluded_at]).to eq([ 'presence' ])
    end
  end

  context 'external_user' do
    it 'should error when does not have advocate role' do
      claim.external_user = litigator
      should_error_with(claim, :external_user, "must have advocate role")
    end

    it 'should error if not present, regardless' do
      claim.external_user = nil
      should_error_with(claim, :external_user, "blank")
    end

    it 'should error if does not belong to the same provider as the creator' do
      claim.creator = create(:external_user, :advocate)
      claim.external_user = create(:external_user, :advocate)
      should_error_with(claim, :external_user, "Creator and advocate must belong to the same provider")
    end
  end

  context 'creator' do
    it 'should error when their provider does not have AGFS role' do
      claim.creator = litigator
      should_error_with(claim, :creator, "must be from a provider with permission to submit AGFS claims")
    end
  end

  context 'advocate_category' do
    it 'should error if not present' do
      claim.advocate_category = nil
      should_error_with(claim, :advocate_category,"blank")
    end

    it 'should error if not in the available list' do
      claim.advocate_category = 'not-a-QC'
      should_error_with(claim, :advocate_category,"Advocate category must be one of those in the provided list")
    end

    valid_entries = ['QC', 'Led junior', 'Leading junior', 'Junior alone']
    valid_entries.each do |valid_entry|
      it "should not error if '#{valid_entry}' specified" do
        claim.advocate_category = valid_entry
        should_not_error(claim, :advocate_category)
      end
    end
  end

  context 'offence' do

    before { claim.offence = nil }

    it 'should error if not present for non-fixed fee case types' do
      claim.case_type.is_fixed_fee = false
      should_error_with(claim, :offence, "blank")
    end

    it 'should NOT error if not present for fixed fee case types' do
      claim.case_type.is_fixed_fee = true
      should_not_error(claim,:offence)
    end
  end

end
