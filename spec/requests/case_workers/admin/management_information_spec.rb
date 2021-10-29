# frozen_string_literal: true

RSpec.shared_examples 'case worker not authorized' do
  context 'when signed in as a case worker' do
    let(:persona) { create(:case_worker) }
    let(:report_type) { 'management_information' }

    it 'returns http redirect status' do
      subject
      expect(response).to have_http_status(:redirect)
    end

    it 'redirects to users root url' do
      is_expected.to redirect_to(case_workers_root_url)
    end
  end
end

RSpec.shared_examples 'external user not authorized' do
  context 'when signed in as an external user admin' do
    let(:persona) { create(:external_user, :agfs_lgfs_admin) }
    let(:report_type) { 'management_information' }

    it 'returns http redirect status' do
      subject
      expect(response).to have_http_status(:redirect)
    end

    it 'redirects to users root url' do
      is_expected.to redirect_to(external_users_root_url)
    end
  end
end

RSpec.describe 'Management information administration', type: :request do
  before { sign_in persona.user }

  let(:persona) { create(:case_worker, :admin) }

  describe '#GET /case_workers/admin/management_information/index' do
    subject(:get_index) { get case_workers_admin_management_information_path }

    let(:expected_report_types) do
      %w[management_information
         agfs_management_information
         lgfs_management_information
         management_information_v2
         agfs_management_information_v2
         lgfs_management_information_v2
         agfs_management_information_daily_statistics
         lgfs_management_information_daily_statistics
         provisional_assessment
         rejections_refusals
         submitted_claims]
    end

    it_behaves_like 'case worker not authorized'
    it_behaves_like 'external user not authorized'

    it 'assigns available_report_types' do
      get_index
      expect(assigns(:available_report_types).keys).to match_array(expected_report_types)
    end

    it 'returns http success' do
      get_index
      expect(response).to have_http_status(:success)
    end

    it 'renders the template' do
      is_expected.to render_template(:index)
    end
  end

  describe '#GET /case_workers/admin/management_information/download' do
    subject(:download) { get case_workers_admin_management_information_download_path(params: { report_type: report_type }) }

    it_behaves_like 'case worker not authorized'
    it_behaves_like 'external user not authorized'

    context 'when the report type is valid' do
      let(:report_type) { 'management_information' }
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

      let(:report_type) { 'management_information' }

      it { is_expected.to redirect_to case_workers_admin_management_information_url }

      it 'displays error message' do
        download
        expect(flash[:alert]).to eq('The requested report is missing')
      end
    end

    context 'when the report type is invalid' do
      let(:report_type) { 'invalid_report_type' }

      it { is_expected.to redirect_to case_workers_admin_management_information_url }

      it 'displays error message' do
        download
        expect(flash[:alert]).to eq('The requested report type is not supported')
      end
    end
  end

  describe '#GET /case_workers/admin/management_information/generate' do
    subject(:regenerate) { get case_workers_admin_management_information_generate_path(params: { report_type: report_type }) }

    it_behaves_like 'case worker not authorized'
    it_behaves_like 'external user not authorized'

    context 'for a valid report type' do
      let(:report_type) { 'management_information' }

      before do
        allow(StatsReportGenerationJob).to receive(:perform_later).with(report_type)
      end

      it { is_expected.to redirect_to(case_workers_admin_management_information_url) }

      it 'displays message to indicate background job scheduled' do
        regenerate
        expect(flash[:alert]).to eq('A background job has been scheduled to regenerate the report. Please refresh this page in a few minutes.')
      end

      it 'starts a ManagemenInformationGeneration job' do
        regenerate
        expect(StatsReportGenerationJob).to have_received(:perform_later).with(report_type)
      end
    end

    context 'for an invalid report type' do
      let(:report_type) { 'invalid_report_type' }

      it { is_expected.to redirect_to(case_workers_admin_management_information_url) }

      it 'displays message to indicate report job schedule failure' do
        regenerate
        expect(flash[:alert]).to eq('The requested report type is not supported')
      end
    end
  end
end
