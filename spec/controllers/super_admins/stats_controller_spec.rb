require 'rails_helper'

RSpec.describe SuperAdmins::StatsController do
  context 'when not logged in as Super Admin' do
    it 'redirects the user' do
      get :show
      expect(response).to have_http_status(:found)
    end
  end

  context 'when logged in as Super Admin' do
    let(:super_admin) { create(:super_admin) }

    before do
      sign_in(super_admin.user)
      get :show
    end

    it 'uses the show template' do
      expect(response).to render_template(:show)
    end

    it 'returns a 200' do
      expect(response).to have_http_status(:ok)
    end

    it 'provides default dates when not provided prams' do
      expect([assigns(:from), assigns(:to)]).to eq([
                                                     Time.zone.today.at_beginning_of_month.to_formatted_s(:short),
                                                     Time.zone.today.to_formatted_s(:short)
                                                   ])
    end

    it 'provides default dates when not provided empty params' do
      get :show, params: { 'date_from(3i)': '', 'date_from(2i)': '', 'date_from(1i)': '',
                           'date_to(3i)': '', 'date_to(2i)': '', 'date_to(1i)': '' }
      expect([assigns(:from), assigns(:to)]).to eq([Time.zone.today.at_beginning_of_month.to_formatted_s(:short),
                                                    Time.zone.today.to_formatted_s(:short)])
    end

    it 'processes dates when provided params' do
      get :show, params: { 'date_from(3i)': '01', 'date_from(2i)': '08', 'date_from(1i)': '2023',
                           'date_to(3i)': '31', 'date_to(2i)': '08', 'date_to(1i)': '2023' }
      expect([assigns(:from), assigns(:to)]).to eq(['01 Aug', '31 Aug'])
    end

    it 'provides default dates when given invalid params' do
      get :show, params: { 'date_from(3i)': '01', 'date_from(2i)': '02', 'date_from(1i)': '2023',
                           'date_to(3i)': '01', 'date_to(2i)': '01', 'date_to(1i)': '2023' }
      expect([assigns(:from), assigns(:to)]).to eq([Time.zone.today.at_beginning_of_month.to_formatted_s(:short),
                                                    Time.zone.today.to_formatted_s(:short)])
    end

    it 'displays an error when given invalid params' do
      get :show, params: { 'date_from(3i)': '01', 'date_from(2i)': '02', 'date_from(1i)': '2023',
                           'date_to(3i)': '01', 'date_to(2i)': '01', 'date_to(1i)': '2023' }
      expect(assigns(:date_err)).to be(true)
    end
  end
end
