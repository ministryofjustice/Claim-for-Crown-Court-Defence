require 'rails_helper'

RSpec.describe RepresentationOrderPresenter do


  it 'should format a summary' do
    reporder = FactoryGirl.build :representation_order
    presenter = RepresentationOrderPresenter.new(reporder, view)
  end



end
