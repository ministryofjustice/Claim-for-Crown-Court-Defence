require 'rails_helper'

RSpec.describe CaseWorkers::Admin::ManagementInformationController, type: :controller do
  let(:case_worker_admin) { create(:case_worker, :admin) }
  let(:case_worker) { create(:case_worker) }

  before { sign_in persona.user }

  context 'when signed in as an admin' do
    let(:persona) { case_worker_admin }

    describe 'GET #index' do
      before { get :index }

      it 'returns http success' do
        expect(response).to have_http_status(:success)
      end

      it 'renders the template' do
        expect(response).to render_template(:index)
      end
    end

    describe '#GET download' do
      context 'for a valid report type' do
        let(:report_type) { 'management_information' }

        context 'using DB storage' do
          let(:content) { 'header1,header2,header3' }
          let!(:stats_report) { create(:stats_report, report_name: 'management_information', report: content) }

          before do
            get :download, params: { report_type: report_type }
          end

          it 'returns http success' do
            expect(response).to have_http_status(:success)
          end

          it 'renders the template' do
            expect(response.headers['Content-Type']).to eq 'text/csv'
          end
        end

        context 'using S3 storage' do
          let(:content) { 'header1,header2,header3' }
          let(:document) { StringIO.new(content) }
          let!(:stats_report) {
            create(:stats_report,
                   report_name: report_type,
                   document: document,
                   document_file_name: "#{report_type}_#{Time.now.to_s(:number)}.csv",
                   document_content_type: 'text/csv'
                  )
          }

          before do
            get :download, params: { report_type: report_type }
          end

          after { document.close }

          it 'returns http success' do
            expect(response).to have_http_status(:success)
          end

          it 'renders the template' do
            expect(response.headers['Content-Type']).to eq 'text/csv'
          end
        end
      end

      context 'for an invalid report type' do
        let(:report_type) { 'invalid_report_type' }

        before do
          get :download, params: { report_type: report_type }
        end

        it 'redirects to the management information page with an error' do
          expect(response).to have_http_status(:redirect)
          expect(response).to redirect_to(case_workers_admin_management_information_url)
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
