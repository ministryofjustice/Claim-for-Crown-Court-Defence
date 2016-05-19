require 'rails_helper'

RSpec.describe CaseConclusionsController, type: :controller do

  let(:params)          { { litigator_type: 'new', elected_case: 'false', transfer_stage_id: 30 } }
  let(:transfer_detail) { build :transfer_detail, litigator_type: 'new', elected_case: false, transfer_stage_id: 10 }

  describe 'GET index' do

    context 'basics' do
      before { xhr :get, :index, params }
      it 'should assign @transfer_details' do
        expect(assigns(:transfer_detail)).to have_attributes(litigator_type: 'new', elected_case: false, transfer_stage_id: 30)
      end

      it 'should render the index template' do
        expect(response).to render_template(:index)
      end
    end

    context 'for new litigator_type' do
      before { xhr :get, :index, params }
      it 'should assign @transfer_stage_label_text to say start' do
        expect(assigns(:transfer_stage_label_text)).to_not be_nil
        expect(assigns(:transfer_stage_label_text)).to eql 'When did you start acting?'
      end

      it 'should assign @transfer_date_label_text to say started' do
        expect(assigns(:transfer_date_label_text)).to_not be_nil
        expect(assigns(:transfer_date_label_text)).to eql 'Date started acting'
      end
    end

    context 'for original litigator type' do
      before do
        params[:litigator_type] = 'original'
        xhr :get, :index, params
      end
      it 'should assign @transfer_stage_label_text to say stop' do
        expect(assigns(:transfer_stage_label_text)).to eql 'When did you stop acting?'
      end

      it 'should assign @transfer_date_label_text to say stopped' do
        expect(assigns(:transfer_date_label_text)).to eql 'Date stopped acting'
      end
    end
  end

end
