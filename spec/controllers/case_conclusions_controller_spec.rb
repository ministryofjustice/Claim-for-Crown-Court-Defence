require 'rails_helper'

RSpec.describe CaseConclusionsController, type: :controller do

  let(:params)          { { litigator_type: 'new', elected_case: 'false', transfer_stage_id: 30 } }
  let(:transfer_detail) { build :transfer_detail, litigator_type: 'new', elected_case: false, transfer_stage_id: 10 }

  describe 'GET index' do
    it 'should assign @transfer_details' do
      xhr :get, :index, params
      expect(assigns(:transfer_detail)).to have_attributes(litigator_type: 'new', elected_case: false, transfer_stage_id: 30)
    end

    it 'should assign @transfer_stage_label_text' do
      xhr :get, :index, params
      expect(assigns(:transfer_stage_label_text)).to_not be_nil
      expect(assigns(:transfer_stage_label_text)).to eql 'When did you start acting?'
    end

    it 'should modify transfer stage label text based on the litigator type' do
      params[:litigator_type] = 'original'
      xhr :get, :index, params
      expect(assigns(:transfer_stage_label_text)).to eql 'When did you stop acting?'
    end

    it 'should assign @transfer_date_label' do
      xhr :get, :index, params
      expect(assigns(:transfer_date_label_text)).to_not be_nil
      expect(assigns(:transfer_date_label_text)).to eql 'Date started acting'
    end

    it 'should modify transfer date label text based on the litigator type' do
      params[:litigator_type] = 'original'
      xhr :get, :index, params
      expect(assigns(:transfer_date_label_text)).to eql 'Date stopped acting'
    end

    it 'should render the index template' do
      xhr :get, :index, params
      expect(response).to render_template(:index)
    end
  end
end
