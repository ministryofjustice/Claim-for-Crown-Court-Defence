require 'rails_helper'

RSpec.describe CaseWorkers::Admin::ManagementInformationController, type: :controller do
  before { sign_in persona.user }

  context 'when signed in as an admin' do
    let(:persona) { create(:case_worker, :admin) }

    describe 'GET #index' do
      let(:expected_report_types) do
        %w[management_information
           agfs_management_information
           lgfs_management_information
           management_information_v2
           agfs_management_information_v2
           lgfs_management_information_v2
           provisional_assessment
           rejections_refusals
           submitted_claims]
      end

      before { get :index }

      it 'assigns available_report_types' do
        expect(assigns(:available_report_types).keys).to match_array(expected_report_types)
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

      let(:report_type) { 'management_information' }

      context 'when the report type is valid' do
        let(:test_url) { 'https://example.com/mi_report.csv#123abc' }

        before do
          stats_report = create(:stats_report, :with_document, report_name: report_type)
          allow(Stats::StatsReport).to receive(:most_recent_by_type).and_return(stats_report)
          allow(stats_report.document.blob).to receive(:url).and_return(test_url)

          download
        end

        it { is_expected.to redirect_to test_url }
      end

      context 'when the report is complete but the file is missing' do
        before { create :stats_report, report_name: report_type }

        it { is_expected.to redirect_to case_workers_admin_management_information_url }

        it 'displays an error' do
          download
          expect(flash[:alert]).to eq('The requested report is missing')
        end
      end

      context 'when the report type is invalid' do
        let(:report_type) { 'invalid_report_type' }

        it { is_expected.to redirect_to case_workers_admin_management_information_url }

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
          expect(flash[:notification]).to eq('Refresh this page in a few minutes to download the new report.')
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
    let(:persona) { create(:case_worker) }

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
