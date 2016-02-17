require 'rails_helper'

describe Claim::BaseClaimSubModelValidator do

  let(:claim)               { FactoryGirl.create :claim }
  let(:defendant)           { claim.defendants.first }

  before(:each)              { claim.force_validation = true }

  it 'should call the validators on all the defendants' do
    expect(claim.defendants).to have(1).members
    expect_any_instance_of(DefendantValidator).to receive(:validate_date_of_birth).at_least(:once)
    claim.valid?
  end

  it 'should call the validator on all the representation orders' do
    expect(defendant.representation_orders).to have(2).items
    expect_any_instance_of(RepresentationOrderValidator).to receive(:validate_representation_order_date).at_least(:once)
    claim.valid?
  end

  context 'fees' do
    before(:each) do
      @basic_fee = FactoryGirl.create :basic_fee, :with_date_attended, claim: claim
      @misc_fee = FactoryGirl.create :misc_fee,:with_date_attended, claim: claim
      FactoryGirl.create :date_attended, attended_item: @misc_fee
      claim.fees.map(&:dates_attended).flatten      # iterate through the fees and dates attended so that the examples below know they have been created
    end

    it 'should call the validator on all the attended dates for all the fees' do
      expect(claim.fees).to have(3).members # because the claim factory includes one fee
      expect_any_instance_of(DateAttendedValidator).to receive(:validate_date).at_least(:once)
      claim.valid?
    end
  end

  context 'expenses' do
    before(:each) do
      @expense = FactoryGirl.create :expense, :with_date_attended, claim: claim
      FactoryGirl.create :date_attended, attended_item: @expense
      claim.expenses.map(&:dates_attended).flatten       # iterate through the expenses and dates attended so that the examples below know they have been created
      claim.force_validation = true
    end

    it 'should call the validator on all the attended dates for all the expenses' do
      expect(claim.expenses).to have(1).member
      expect(claim.expenses.first.dates_attended).to have(2).members
      expect_any_instance_of(DateAttendedValidator).to receive(:validate_date).at_least(:once)
      claim.valid?
    end
  end

  context 'bubbling up errors to the claim' do
    before(:each) do
      claim.force_validation = false
    end

    context 'bubbling up errors from defendant to claim' do
      before do
        claim.force_validation = false
      end
      it 'should transfer errors up to claim' do
        claim.defendants.first.update(date_of_birth: nil)
        claim.defendants.first.update(first_name: nil)
        claim.force_validation = true
        claim.reload.valid?

        expect(claim.errors[:defendant_1_date_of_birth]).to eq(['blank'])
        expect(claim.errors[:defendant_1_first_name]).to eq(['blank'])
      end
    end


    context 'bubbling up errors two levels to the claim' do

      let(:expected_results) do
          {
            defendant_1_representation_order_1_maat_reference:            "invalid",
            defendant_1_representation_order_1_representation_order_date: "invalid",
            defendant_1_date_of_birth:                                    "blank",
          }
        end

      before(:each) do
        claim.defendants.first.update(date_of_birth: nil)
        claim.defendants.first.representation_orders.first.update(maat_reference: 'XYZ')
        claim.defendants.first.representation_orders.first.update(representation_order_date: 20.years.ago)
        claim.save!
        claim.force_validation = true

        claim.valid?
      end

      it 'should bubble up the error from reporder to defendant and then to the claim' do
        expected_results.each do |key, message|
          expect(claim.errors[key]).to eq( [message] ), "EXPECTED: #{key} to have error [\"#{message}\"] but found #{claim.errors[key]}"
        end
      end

    end

  end

end
