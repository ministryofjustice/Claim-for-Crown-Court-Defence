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

RSpec.shared_examples 'report validator' do
  it { is_expected.to redirect_to(case_workers_admin_management_information_url) }

  it 'displays message to indicate report job schedule failure' do
    subject
    expect(flash[:alert]).to eq('The requested report type is not supported')
  end
end

RSpec.shared_examples 'date validator' do
  it { is_expected.to redirect_to(case_workers_admin_management_information_url) }

  it 'displays message to indicate date is invalid' do
    subject
    expect(flash[:alert]).to eq('The supplied date is invalid')
  end
end

RSpec.describe 'Management information administration', type: :request do
  before { sign_in persona.user }

  let(:persona) { create(:case_worker, :admin) }

  describe '#GET /case_workers/admin/management_information/index' do
    subject(:request) { get case_workers_admin_management_information_path }

    let(:expected_report_types) do
      %w[management_information
         agfs_management_information
         lgfs_management_information
         management_information_v2
         agfs_management_information_v2
         lgfs_management_information_v2
         agfs_management_information_weekly_statistics
         lgfs_management_information_weekly_statistics
         provisional_assessment
         rejections_refusals
         submitted_claims]
    end

    it_behaves_like 'case worker not authorized'
    it_behaves_like 'external user not authorized'

    it 'assigns available_reports' do
      request
      expect(assigns(:available_reports).keys.map(&:to_s)).to match_array(expected_report_types)
    end

    it 'returns http success' do
      request
      expect(response).to have_http_status(:success)
    end

    it 'renders the template' do
      is_expected.to render_template(:index)
    end
  end

  describe '#GET /case_workers/admin/management_information/download' do
    subject(:request) do
      get case_workers_admin_management_information_download_path(params: { report_type: report_type })
    end

    it_behaves_like 'case worker not authorized'
    it_behaves_like 'external user not authorized'

    context 'with a valid report type' do
      let(:report_type) { 'management_information' }
      let(:test_url) { 'https://example.com/mi_report.csv#123abc' }

      before do
        stats_report = create(:stats_report, :with_document, report_name: report_type)
        allow(Stats::StatsReport).to receive(:most_recent_by_type).and_return(stats_report)
        allow(stats_report.document.blob).to receive(:url).and_return(test_url)

        request
      end

      it { is_expected.to redirect_to test_url }
    end

    context 'with a report type that is valid and completed but the file is missing' do
      before { create(:stats_report, report_name: report_type) }

      let(:report_type) { 'management_information' }

      it { is_expected.to redirect_to case_workers_admin_management_information_url }

      it 'displays error message' do
        request
        expect(flash[:alert]).to eq('The requested report is missing')
      end
    end

    context 'with an invalid report type' do
      let(:report_type) { 'invalid_report_type' }

      it_behaves_like 'report validator'
    end
  end

  describe '#GET /case_workers/admin/management_information/generate' do
    subject(:request) do
      get case_workers_admin_management_information_generate_path(params: { report_type: report_type })
    end

    it_behaves_like 'case worker not authorized'
    it_behaves_like 'external user not authorized'

    context 'with a valid report type' do
      let(:report_type) { 'management_information' }

      before do
        allow(StatsReportGenerationJob).to receive(:perform_later).with(report_type)
      end

      it { is_expected.to redirect_to(case_workers_admin_management_information_url) }

      it 'displays message to indicate background job scheduled' do
        request
        expect(flash[:alert])
          .to eq('A background job has been scheduled to regenerate the report. ' \
                 'Please refresh this page in a few minutes.')
      end

      it 'starts a ManagemenInformationGeneration job' do
        request
        expect(StatsReportGenerationJob).to have_received(:perform_later).with(report_type)
      end
    end

    context 'with an invalid report type' do
      let(:report_type) { 'invalid_report_type' }

      it_behaves_like 'report validator'
    end
  end

  describe '#POST /case_workers/admin/management_information/create' do
    subject(:request) { post case_workers_admin_management_information_create_path(params: params) }

    before do
      allow(StatsReportGenerationJob).to receive(:perform_later).with(instance_of(String), day: instance_of(Date))
    end

    context 'with a valid report type and valid date' do
      let(:params) do
        { report_type: 'agfs_management_information_weekly_statistics',
          'day(3i)' => '25',
          'day(2i)' => '12',
          'day(1i)' => '2020' }
      end

      it 'returns http redirect' do
        request
        expect(response).to have_http_status(:redirect)
      end

      it { is_expected.to redirect_to(case_workers_admin_management_information_url) }

      it 'starts a StatsReportGenerationJob for report with a date' do
        request
        expect(StatsReportGenerationJob)
          .to have_received(:perform_later)
          .with('agfs_management_information_weekly_statistics', day: Date.parse('2020-12-25'))
      end

      it 'displays message to indicate background job scheduled' do
        request
        expect(flash[:alert])
          .to eq('A background job has been scheduled to regenerate the report. ' \
                 'Please refresh this page in a few minutes.')
      end
    end

    context 'with an invalid report type and valid date' do
      let(:params) do
        { report_type: 'invalid_report_type',
          'day(3i)' => '25',
          'day(2i)' => '12',
          'day(1i)' => '2020' }
      end

      it_behaves_like 'report validator'
    end

    context 'with valid report type but no date' do
      let(:params) do
        { report_type: 'agfs_management_information_weekly_statistics' }
      end

      it_behaves_like 'date validator'
    end

    context 'with valid report type but an invalid date' do
      let(:params) do
        { report_type: 'agfs_management_information_weekly_statistics',
          'day(3i)' => '-1',
          'day(2i)' => '12',
          'day(1i)' => '2020' }
      end

      it_behaves_like 'date validator'
    end
  end
end
