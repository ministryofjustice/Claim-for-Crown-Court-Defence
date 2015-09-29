require 'rails_helper'

describe 'Validations on Claim submodels' do

  let(:claim)               { FactoryGirl.create :claim }
  let(:defendant)           { claim.defendants.first }

  before(:each)              { claim.force_validation = true }


  it 'should call the validators on all the defendants' do
    expect(claim.defendants).to  have(1).members
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
      @basic_fee = FactoryGirl.create :fee, :fixed, :with_date_attended, claim: claim
      @misc_fee = FactoryGirl.create :fee, :misc, :with_date_attended, claim: claim
      FactoryGirl.create :date_attended, attended_item: @misc_fee
      claim.fees.map(&:dates_attended).flatten      # iterate through the fees and dates attended so that the examples below know they have been created
    end

    it 'should call the validator on all the attended dates for all the fees' do
      expect(claim.fees).to have(3).members # because the claim factory includes one fee
      expect(claim.fees.second.dates_attended).to have(1).member
      expect(claim.fees.last.dates_attended).to have(2).members
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

  
end
