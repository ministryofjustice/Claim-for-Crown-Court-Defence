require 'rails_helper'
require_relative '../validation_helpers'
require_relative 'shared_examples_for_advocate_litigator'

describe Claim::InterimClaimValidator do

  include ValidationHelpers
  include_context "force-validation"

  let(:litigator) { build(:external_user, :litigator) }
  let(:claim)     { create(:interim_claim) }

  include_examples "common advocate litigator validations", :litigator
  include_examples "common litigator validations"

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
          :first_day_of_trial,
          :estimated_trial_length,
          :trial_concluded_at,
          :retrial_started_at,
          :retrial_estimated_length,
          :effective_pcmh_date,
          :legal_aid_transfer_date,
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
