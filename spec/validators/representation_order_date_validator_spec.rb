require 'rails_helper'
require File.dirname(__FILE__) + '/date_validation_helpers'

describe RepresentationOrderDateValidator do 
  include RspecDateValidationHelpers

  let(:claim)         { FactoryGirl.build :claim, force_validation: true }
  let(:defendant)     { FactoryGirl.build :defendant, claim: claim }
  let(:reporder)      { FactoryGirl.build :representation_order, defendant: defendant }

  context 'representation_order_date' do
    it { should_error_if_not_present(reporder, :representation_order_date, "Please enter a valid representation order date") }
    it { should_error_if_in_future(reporder, :representation_order_date, "Representation order date must not be in the future") }
    it { should_error_if_not_too_far_in_the_past(reporder, :representation_order_date, "The representation order date may not be more than 5 years ago") }
  end

  context 'stand-alone rep order' do
    it 'should always be valid if not attached to a defendant or claim' do
      reporder = FactoryGirl.build :representation_order, defendant: nil, representation_order_date: nil
      expect(reporder).to be_valid
    end
  end

  context 'multiple representation orders' do

    let(:claim)       { FactoryGirl.create :claim }
    let(:ro1)         { claim.defendants.first.representation_orders.first }
    let(:ro2)         { claim.defendants.first.representation_orders.last }


    it 'should be valid if the second reporder is dated after the first' do
      ro1.update(representation_order_date: 2.weeks.ago)
      ro2.update(representation_order_date: 1.day.ago)
      claim.force_validation = true
      expect(ro2).to be_valid
    end

    it 'should be invalid if second reporder dated before first' do
      ro2.representation_order_date = ro1.representation_order_date - 1.day
      claim.force_validation = true
      expect(ro2).not_to be_valid
      expect(ro2.errors[:representation_order_date]).to include('The date of the second and subsequent representation orders must not be before the date of the first represenation order')
    end
  end


end