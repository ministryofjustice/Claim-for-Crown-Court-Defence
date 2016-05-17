require 'rails_helper'

RSpec.describe CaseConclusionsController, type: :controller do

  let(:params)          { { litigator_type: 'new', elected_case: 'false', transfer_stage_id: 30 } }
  let(:transfer_detail) { build :transfer_detail, litigator_type: 'new', elected_case: false, transfer_stage_id: 10 }

  describe 'GET index' do
    it 'should assign dummy transfer details' do
      xhr :get, :index, params
      expect(assigns(:transfer_detail)).to have_attributes(litigator_type: 'new', elected_case: false, transfer_stage_id: 30)
    end

    it 'should render the index template' do
      xhr :get, :index, params
      expect(response).to render_template(:index)
    end
  end
end
