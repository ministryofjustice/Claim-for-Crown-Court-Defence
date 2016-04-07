require 'rails_helper'
require_relative '../validation_helpers'

describe Claim::LitigatorClaimSubModelValidator do

  let(:claim) { FactoryGirl.create :litigator_claim }

  before(:each) do
    claim.force_validation = true
  end

  context 'partial validation' do
    let(:step1_has_one) { [] }
    let(:step2_has_one) { [ :graduated_fee, :assessment, :certification ] }

    let(:step1_has_many) { [ :defendants ] }
    let(:step2_has_many) { [ :misc_fees, :disbursements, :expenses, :messages, :redeterminations, :documents ] }

    context 'from web' do
      before do
        claim.source = 'web'
      end

      context 'step 1' do
        before do
          claim.form_step = 1
        end

        it 'should validate has_one associations for this step' do
          step1_has_one.each do |association|
            expect_any_instance_of(described_class).to receive(:validate_association_for).with(claim, association)
          end

          step2_has_one.each do |association|
            expect_any_instance_of(described_class).not_to receive(:validate_association_for).with(claim, association)
          end

          claim.valid?
        end

        it 'should validate has_many associations for this step' do
          step1_has_many.each do |association|
            expect_any_instance_of(described_class).to receive(:validate_collection_for).with(claim, association)
          end

          step2_has_many.each do |association|
            expect_any_instance_of(described_class).not_to receive(:validate_collection_for).with(claim, association)
          end

          claim.valid?
        end
      end

      context 'step 2' do
        before do
          claim.form_step = 2
        end

        it 'should validate has_one associations for this step' do
          step2_has_one.each do |association|
            expect_any_instance_of(described_class).to receive(:validate_association_for).with(claim, association)
          end

          claim.valid?
        end

        it 'should validate has_many associations for this step' do
          step2_has_many.each do |association|
            expect_any_instance_of(described_class).to receive(:validate_collection_for).with(claim, association)
          end

          claim.valid?
        end
      end
    end

    context 'from API' do
      before do
        claim.source = 'api'
      end

      it 'should validate all the has_one associations for all the steps' do
        (step1_has_one + step2_has_one).each do |association|
          expect_any_instance_of(described_class).to receive(:validate_association_for).with(claim, association)
        end

        claim.valid?
      end

      it 'should validate all the has_many associations for all the steps' do
        (step1_has_many + step2_has_many).each do |association|
          expect_any_instance_of(described_class).to receive(:validate_collection_for).with(claim, association)
        end

        claim.valid?
      end
    end
  end
end
