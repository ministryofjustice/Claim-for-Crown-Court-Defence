require 'rails_helper'

RSpec.describe Claim::BaseClaimSubModelValidator, type: :validator do
  subject(:validator) { described_class.new }

  let(:claim) { create(:claim) }
  let(:defendant) { claim.defendants.first }

  before do
    claim.force_validation = true
    claim.form_step = :defendants
  end

  it_behaves_like 'a custom CCCD associated error handler'

  it 'calls the validators on all the defendants' do
    expect(claim.defendants).to have(1).members
    expect_any_instance_of(DefendantValidator).to receive(:validate_date_of_birth).at_least(:once)
    claim.valid?
  end

  it 'calls the validator on all the representation orders' do
    expect(defendant.representation_orders).to have(2).items
    expect_any_instance_of(RepresentationOrderValidator).to receive(:validate_representation_order_date).at_least(:once)
    claim.valid?
  end

  context 'fees' do
    before do
      @basic_fee = create(:basic_fee, :with_date_attended, claim:)
      @misc_fee = create(:misc_fee, :with_date_attended, claim:)
      create(:date_attended, attended_item: @misc_fee)
      claim.fees.map(&:dates_attended).flatten # iterate through the fees and dates attended so that the examples below know they have been created
      claim.form_step = :basic_fees
    end

    it 'calls the validator on all the attended dates for all the fees' do
      expect(claim.fees).to have(3).members # because the claim factory includes one fee
      expect_any_instance_of(DateAttendedValidator).to receive(:validate_date).at_least(:once)
      claim.valid?
    end
  end

  context 'expenses' do
    before do
      @expense = create(:expense, :with_date_attended, claim:)
      create(:date_attended, attended_item: @expense)
      claim.expenses.map(&:dates_attended).flatten # iterate through the expenses and dates attended so that the examples below know they have been created
      claim.force_validation = true
      claim.form_step = :offence_details
    end
  end

  context 'bubbling up errors to the claim' do
    before do
      claim.force_validation = false
    end

    context 'bubbling up errors from defendant to claim' do
      before do
        claim.force_validation = false
      end

      it 'transfers errors up to claim' do
        claim.defendants.first.update(date_of_birth: nil)
        claim.defendants.first.update(first_name: nil)
        claim.force_validation = true
        claim.reload.valid?

        expect(claim.errors[:defendants_attributes_0_date_of_birth]).to eq(['Enter a date of birth'])
        expect(claim.errors[:defendants_attributes_0_first_name]).to eq(['Enter a first name'])
      end
    end

    context 'bubbling up errors two levels to the claim' do
      let(:expected_results) do
        {
          defendants_attributes_0_representation_orders_attributes_0_representation_order_date:
            'Representation order date is too far in the past',
          defendants_attributes_0_date_of_birth: 'Enter a date of birth'
        }
      end

      context 'when claim has case type requiring MAAT reference' do
        before do
          expected_results[:defendants_attributes_0_representation_orders_attributes_0_maat_reference] =
            'Enter a valid MAAT reference'

          claim.case_type.update_column(:requires_maat_reference, true)

          claim.defendants.first.update(date_of_birth: nil)
          claim.defendants.first.representation_orders.first.update(maat_reference: 'XYZ')
          claim.defendants.first.representation_orders.first.update(representation_order_date: 20.years.ago)
          claim.save!
          claim.force_validation = true

          claim.valid?
        end

        it 'bubbles up the error from reporder to defendant and then to the claim' do
          expected_results.each do |key, message|
            expect(claim.errors[key]).to eq([message]), "EXPECTED: #{key} to have error [\"#{message}\"] but found #{claim.errors[key]}"
          end
        end
      end

      context 'when claims does not have case type requiring MAAT reference' do
        before do
          claim.case_type.update_column(:requires_maat_reference, false)

          claim.defendants.first.update(date_of_birth: nil)
          claim.defendants.first.representation_orders.first.update(maat_reference: 'XYZ')
          claim.defendants.first.representation_orders.first.update(representation_order_date: 20.years.ago)
          claim.save!
          claim.force_validation = true

          claim.valid?
        end

        before do
          claim.case_type.update_column(:requires_maat_reference, false)
        end

        it 'bubbles up the error from reporder to defendant and then to the claim' do
          expected_results.each do |key, message|
            expect(claim.errors[key]).to eq([message]), "EXPECTED: #{key} to have error [\"#{message}\"] but found #{claim.errors[key]}"
          end
        end
      end
    end
  end
end
