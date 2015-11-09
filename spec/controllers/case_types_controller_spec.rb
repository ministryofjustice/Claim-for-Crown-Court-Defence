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
