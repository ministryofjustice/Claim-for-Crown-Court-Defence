# == Schema Information
#
# Table name: offences
#
#  id               :integer          not null, primary key
#  description      :string
#  offence_class_id :integer
#  created_at       :datetime
#  updated_at       :datetime
#

require 'rails_helper'

RSpec.describe OffencesController, type: :controller do

  before(:each) do
    create :offence, :with_fee_scheme, description: "Offence 1"
    create :offence, :with_fee_scheme, description: "Offence 3"
    create :offence, :with_fee_scheme, description: "Offence 2"
  end



  describe 'GET index' do
    it 'should return all offences if no description present' do
      xhr :get, :index
      expect(assigns(:offences).size).to eq 3
      expect(assigns(:offences).map(&:description)).to eq( ['Offence 1', 'Offence 2', 'Offence 3' ])
    end

    it 'should just get the matching offence' do
      xhr :get, :index, {description: 'Offence 3'}
      expect(assigns(:offences).map(&:description)).to eq( [ 'Offence 3'] )
    end
  end
end
