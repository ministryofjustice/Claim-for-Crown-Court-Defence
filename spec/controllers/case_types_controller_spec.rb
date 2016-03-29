# == Schema Information
#
# Table name: case_types
#
#  id                      :integer          not null, primary key
#  name                    :string
#  is_fixed_fee            :boolean
#  created_at              :datetime
#  updated_at              :datetime
#  requires_cracked_dates  :boolean
#  requires_trial_dates    :boolean
#  allow_pcmh_fee_type     :boolean          default(FALSE)
#  requires_maat_reference :boolean          default(FALSE)
#  requires_retrial_dates  :boolean          default(FALSE)
#  roles                   :string
#  parent_id               :integer
#  grad_fee_code           :string
#

require 'rails_helper'

RSpec.describe CaseTypesController, type: :controller do

  let!(:case_type_1) { create :case_type, name: 'Case Type 1' }

  describe 'GET show' do
    it 'should get case type with the id' do
      xhr :get, :show, id: case_type_1.id
      expect(assigns(:case_type)).to eq(case_type_1)
    end

    it 'should render the show template' do
      xhr :get, :show, id: case_type_1.id
      expect(response).to render_template(:show)
    end
  end
end
