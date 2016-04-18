require 'rails_helper'
require_relative '../validation_helpers'
require_relative 'shared_examples_for_advocate_litigator'

describe Claim::LitigatorClaimValidator do

  include ValidationHelpers
  include_context "force-validation"

  let(:advocate)      { build(:external_user, :advocate) }
  let(:litigator)     { build(:external_user, :litigator) }
  let(:claim)         { create(:litigator_claim) }
  let(:offence)       { build(:offence) }
  let(:offence_class) { build(:offence_class, class_letter: 'X', description: 'Offences of dishonesty in Class F where the value in is in excess of £100,000') }
  let(:misc_offence)  { create(:offence, description: 'Miscellaneous/other', offence_class: offence_class) }

  include_examples "common advocate litigator validations", :litigator

  context 'case concluded at date' do
    let(:claim)    { build :litigator_claim }
    before(:each)  { claim.force_validation = true}

    it 'is invalid when absent' do
      claim.case_concluded_at = nil
      claim.valid?
      expect(claim.errors[:case_concluded_at]).to eq([ 'blank' ])
    end

    it 'is valid when present' do
      claim.case_concluded_at = 1.month.ago
      expect(claim).to be_valid
      expect(claim.errors.key?(:case_concluded_at)).to be false
    end
  end

  context 'external_user' do
    it 'should error when does not have advocate role' do
      claim.external_user = advocate
      should_error_with(claim, :external_user, "must have litigator role")
    end

    it 'should error if not present, regardless' do
      claim.external_user = nil
      should_error_with(claim, :external_user, "blank_litigator")
    end

    it 'should error if does not belong to the same provider as the creator' do
      claim.creator = create(:external_user, :litigator)
      claim.external_user = create(:external_user, :litigator)
      should_error_with(claim, :external_user, "Creator and litigator must belong to the same provider")
    end
  end

  context 'creator' do
    it 'should error when their provider does not have LGFS role' do
      claim.creator = advocate
      should_error_with(claim, :creator, "must be from a provider with permission to submit LGFS claims")
    end
  end

  context 'supplier_number' do
    it 'should error when the supplier number is not valid for litigators' do
      claim.supplier_number = 'XP312'
      should_error_with(claim, :supplier_number, 'invalid')
    end

    it 'should error when the supplier number doesn\'t belong to the provider' do
      claim.supplier_number = '2A267M'
      should_error_with(claim, :supplier_number, 'unknown')
    end
  end

  context 'advocate_category' do
    it 'should be absent' do
      claim.advocate_category = 'QC'
      should_error_with(claim, :advocate_category, "invalid")
      claim.advocate_category = nil
      expect(claim).to be_valid
    end
  end

  context 'offence' do
    before { claim.offence = nil }

    it 'should error if NOT present for any case type' do
      claim.case_type.is_fixed_fee = false
      should_error_with(claim, :offence, "blank")
      claim.case_type.is_fixed_fee = true
      should_error_with(claim, :offence, "blank")
    end

    it 'should error if NOT a Miscellaneous/other offence' do
      claim.offence = offence
      should_error_with(claim, :offence, "invalid")
    end

    it 'should NOT error if a Miscellaneous/other offence' do
      claim.offence = misc_offence
      expect(claim).to be_valid
    end
  end

  context 'partial validation' do
    let(:step1_attributes) {
      [
          :case_type,
          :court,
          :case_number,
          :advocate_category,
          :offence,
          :case_concluded_at
      ]
    }
    let(:step2_attributes) {
      [
          :estimated_trial_length,
          :actual_trial_length,
          :retrial_estimated_length,
          :retrial_actual_length,
          :trial_cracked_at_third,
          :trial_fixed_notice_at,
          :trial_fixed_at,
          :trial_cracked_at,
          :first_day_of_trial,
          :trial_concluded_at,
          :retrial_started_at,
          :retrial_concluded_at,
          :total
      ]
    }

    context 'from web' do
      before do
        claim.source = 'web'
      end

      context 'step 1' do
        before do
          claim.form_step = 1
        end

        it 'should validate only attributes for this step' do
          step1_attributes.each do |attrib|
            expect_any_instance_of(described_class).to receive(:validate_field).with(attrib)
          end

          step2_attributes.each do |attrib|
            expect_any_instance_of(described_class).not_to receive(:validate_field).with(attrib)
          end

          claim.valid?
        end
      end

      context 'step 2' do
        before do
          claim.form_step = 2
        end

        it 'should validate only attributes for this step' do
          step2_attributes.each do |attrib|
            expect_any_instance_of(described_class).to receive(:validate_field).with(attrib)
          end

          step1_attributes.each do |attrib|
            expect_any_instance_of(described_class).not_to receive(:validate_field).with(attrib)
          end

          claim.valid?
        end
      end
    end

    context 'from API' do
      before do
        claim.source = 'api'
      end

      it 'should validate all the attributes for all the steps' do
        (step1_attributes + step2_attributes).each do |attrib|
          expect_any_instance_of(described_class).to receive(:validate_field).with(attrib)
        end

        claim.valid?
      end
    end
  end
end
