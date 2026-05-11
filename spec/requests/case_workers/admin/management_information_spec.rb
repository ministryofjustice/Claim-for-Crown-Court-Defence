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
  it { is_expected.to redirect_to(case_workers_admin_management_information_index_url) }

  it 'displays message to indicate report job schedule failure' do
    subject
    expect(flash[:alert]).to eq('The requested report type is not supported')
  end
end

RSpec.shared_examples 'date validator' do
  it { is_expected.to redirect_to(case_workers_admin_management_information_index_url) }

  it 'displays message to indicate date is invalid' do
    subject
    expect(flash[:alert]).to eq('The supplied date is invalid')
  end
end

RSpec.describe 'Management information administration' do
  before { sign_in persona.user }

  let(:persona) { create(:case_worker, :admin) }

  describe '#GET /case_workers/admin/management_information' do
    subject(:request) { get case_workers_admin_management_information_index_path }

    let(:expected_report_types) do
      %w[management_information
         agfs_management_information
         lgfs_management_information
         fee_scheme_usage
         management_information_v2
         agfs_management_information_v2
         lgfs_management_information_v2
         agfs_management_information_statistics
         lgfs_management_information_statistics
         provisional_assessment
         rejections_refusals
         submitted_claims
         reports_access_details]
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

  describe '#POST /case_workers/admin/management_information' do
    subject(:request) { post case_workers_admin_management_information_index_path(params:) }

    context 'with an invalid report type' do
      let(:params) { { report: { report_type: 'invalid_report_type' } } }

      it_behaves_like 'report validator'
    end

    context 'with a valid report type' do
      let(:params) { { report: { report_type: 'management_information' } } }

      it_behaves_like 'case worker not authorized'
      it_behaves_like 'external user not authorized'

      context 'when the file is present' do
        let(:test_url) { 'https://document.storage/mi_report.csv#123abc' }

        before do
          stats_report = create(:stats_report, :with_document, report_name: 'management_information')
          allow(Stats::StatsReport).to receive(:most_recent_by_type).and_return(stats_report)
          allow(stats_report.document.blob).to receive(:url).and_return(test_url)

          request
        end

        it { is_expected.to redirect_to(test_url) }
      end

      context 'when the file is missing' do
        before { create(:stats_report, report_name: 'management_information') }

        it { is_expected.to redirect_to(case_workers_admin_management_information_index_path) }

        it 'displays error message' do
          request
          expect(flash[:alert]).to eq('The requested report is missing')
        end
      end

      context 'with an update parameter' do
        let(:params) { { report: { report_type: 'management_information', update: 'true' } } }

        before { ActiveJob::Base.queue_adapter = :test }

        it_behaves_like 'case worker not authorized'
        it_behaves_like 'external user not authorized'

        it 'enqueues a StatsReportGenerationJob for specified report' do
          request
          expect(StatsReportGenerationJob)
            .to have_been_enqueued.with(hash_including(report_type: 'management_information'))
                                  .on_queue('stats_reports')
                                  .at(:no_wait)
        end

        it 'displays message to indicate background job enqueued' do
          request
          expect(flash[:notification])
            .to eq('Refresh this page in a few minutes to download the new report.')
        end

        it { is_expected.to redirect_to(case_workers_admin_management_information_index_url) }
      end

      context 'with an update parameter for a report that requires a date' do
        let(:params) do
          {
            report: {
              report_type: 'agfs_management_information_statistics',
              update: 'true',
              'start_at(3i)' => '25',
              'start_at(2i)' => '12',
              'start_at(1i)' => '2020'
            }
          }
        end

        before { ActiveJob::Base.queue_adapter = :test }

        it 'enqueues a StatsReportGenerationJob for specified report with date' do
          request
          expect(StatsReportGenerationJob).to have_been_enqueued.with(
            report_type: 'agfs_management_information_statistics',
            start_at: Date.parse('2020-12-25')
          ).on_queue('stats_reports').at(:no_wait)
        end

        it 'displays message to indicate background job enqueued' do
          request
          expect(flash[:notification])
            .to eq('Refresh this page in a few minutes to download the new report.')
        end

        it { is_expected.to redirect_to(case_workers_admin_management_information_index_url) }
      end

      context 'with an update parameter for a report that requires a date with the date missing' do
        let(:params) { { report: { report_type: 'agfs_management_information_statistics', update: 'true' } } }

        it_behaves_like 'date validator'
      end

      context 'with an update parameter for a report that requires a date with an invalid date' do
        let(:params) do
          {
            report: {
              report_type: 'agfs_management_information_statistics',
              update: 'true',
              'start_at(3i)' => '32',
              'start_at(2i)' => '13',
              'start_at(1i)' => '2020'
            }
          }
        end

        it_behaves_like 'date validator'
      end
    end
  end
end
