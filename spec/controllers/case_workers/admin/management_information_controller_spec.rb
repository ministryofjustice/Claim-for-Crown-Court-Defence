require 'rails_helper'

RSpec.describe CaseWorkers::Admin::ManagementInformationController, type: :controller do
  let(:case_worker_admin) { create(:case_worker, :admin) }
  let(:case_worker) { create(:case_worker) }

  before { sign_in persona.user }

  context 'when signed in as an admin' do
    let(:persona) { case_worker_admin }

    describe 'GET #index' do
      before { get :index }

      it 'assigns available_report_types' do
        expect(assigns(:available_report_types).keys).to match_array(%w[management_information provisional_assessment rejections_refusals])
      end

      it 'returns http success' do
        expect(response).to be_successful
      end

      it 'renders the template' do
        expect(response).to render_template(:index)
      end
    end

    describe '#GET download' do
      subject(:download) { get :download, params: { report_type: report_type } }

      context 'when the report type is valid' do
        let(:report_type) { 'management_information' }
        let(:service_url) { 'https://example.com/document.csv' }

        before do
          create :stats_report, :with_document, report_name: report_type
          ActiveStorage::Current.host = 'https://example.com'
          download
        end

        it 'redirects to the service url of the document' do
          expect(response.location).to match %r{https://example.com}
        end
      end

      context 'when the report is completed but the file is missing' do
        let(:report_type) { 'management_information' }
        let(:stats_report) { create :stats_report, report_name: report_type }

        before do
          create :stats_report, report_name: report_type
        end

        it 'redirects to the management information page' do
          expect(download).to redirect_to case_workers_admin_management_information_url
        end

        it 'displays an error' do
          download
          expect(flash[:alert]).to eq('The requested report is missing')
        end
      end

      context 'when the report type is invalid' do
        let(:report_type) { 'invalid_report_type' }

        it 'redirects to the management information page' do
          expect(download).to redirect_to case_workers_admin_management_information_url
        end

        it 'displays an error' do
          download
          expect(flash[:alert]).to eq('The requested report type is not supported')
        end
      end
    end

    describe '#GET generate' do
      context 'for a valid report type' do
        let(:report_type) { 'management_information' }

        before do
          allow(StatsReportGenerationJob).to receive(:perform_later).with(report_type)
          get :generate, params: { report_type: report_type }
        end

        it 'redirects the user to the management information page with a successful alert message' do
          expect(response).to have_http_status(:redirect)
          expect(response).to redirect_to(case_workers_admin_management_information_url)
          expect(flash[:alert]).to eq('A background job has been scheduled to regenerate the report. Please refresh this page in a few minutes.')
        end

        it 'starts a ManagemenInformationGeneration job' do
          expect(StatsReportGenerationJob).to have_received(:perform_later).with(report_type)
        end
      end

      context 'for an invalid report type' do
        let(:report_type) { 'invalid_report_type' }

        before do
          get :generate, params: { report_type: report_type }
        end

        it 'redirects to the management information page with an error' do
          expect(response).to have_http_status(:redirect)
          expect(response).to redirect_to(case_workers_admin_management_information_url)
          expect(flash[:alert]).to eq('The requested report type is not supported')
        end
      end
    end
  end

  context 'when signed in as a case worker' do
    let(:persona) { case_worker }

    [:index, :download, :generate].each do |view|
      describe "GET ##{view}" do
        before { get view }

        it 'returns an http redirect' do
          expect(response).to have_http_status(:redirect)
        end

        it 'redirect to the login prompt' do
          expect(response).to redirect_to(case_workers_root_url)
        end
      end
    end
  end
end
