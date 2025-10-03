require 'rails_helper'

RSpec.shared_examples 'a successful report generator caller' do
  before { allow(generator).to receive(:call).with(args).and_return(mocked_result) }

  it 'calls generator with expected args' do
    call
    expect(generator).to have_received(:call).with(args)
  end

  it 'marks report as completed' do
    expect { call }.to change(Stats::StatsReport.where(report_name: report_type).completed, :count).by 1
  end

  it 'generates report content' do
    call
    record = Stats::StatsReport.where(report_name: report_type).completed.last
    file_path = ActiveStorage::Blob.service.path_for(record.document.blob.key)
    expect(File.read(file_path)).to eq('some new content')
  end

  context 'when the generator is called' do
    before { allow(generator).to receive(:call).and_call_original }

    it { expect { call }.not_to raise_error }
  end
end

RSpec.describe Stats::StatsReportGenerator, type: :service do
  describe '.call' do
    subject(:call) { described_class.call(report_type:) }

    context 'with an invalid report type' do
      let(:report_type) { 'some-report-type' }

      before { allow(Settings).to receive(:notify_report_errors).and_return(false) }

      it 'raises an invalid report type error' do
        expect { call }.to raise_error(described_class::InvalidReportType)
      end

      it 'does not create a new report' do
        expect { call rescue nil }.not_to change(Stats::StatsReport, :count).from(0)
      end
    end

    context 'with a valid report type that is already in progress' do
      let(:report_type) { 'management_information' }

      before { Stats::StatsReport.create(report_name: report_type, status: 'started') }

      it 'does not create a new report' do
        expect { call }.not_to change(Stats::StatsReport, :count).from(1)
      end
    end

    context 'with a valid report type that is not already in progress' do
      let(:mocked_result) { Stats::Result.new('some new content', 'csv') }

      context 'with simple report type' do
        let(:report_type) { 'submitted_claims' }
        let(:generator) { Stats::SimpleReportGenerator }

        it_behaves_like 'a successful report generator caller' do
          let(:args) { { report_type: 'submitted_claims' } }
        end
      end

      context 'with management information report' do
        let(:report_type) { 'management_information' }
        let(:generator) { Stats::ManagementInformationGenerator }

        it_behaves_like 'a successful report generator caller' do
          let(:args) { { report_type: 'management_information' } }
        end
      end

      context 'with AGFS management information report' do
        let(:report_type) { 'agfs_management_information' }
        let(:generator) { Stats::ManagementInformationGenerator }

        it_behaves_like 'a successful report generator caller' do
          let(:args) { { report_type: 'agfs_management_information', scheme: :agfs } }
        end
      end

      context 'with LGFS management information report' do
        let(:report_type) { 'lgfs_management_information' }
        let(:generator) { Stats::ManagementInformationGenerator }

        it_behaves_like 'a successful report generator caller' do
          let(:args) { { report_type: 'lgfs_management_information', scheme: :lgfs } }
        end
      end

      context 'with management information report v2' do
        let(:report_type) { 'management_information_v2' }
        let(:generator) { Stats::ManagementInformation::DailyReportGenerator }

        it_behaves_like 'a successful report generator caller' do
          let(:args) { { report_type: 'management_information_v2' } }
        end
      end

      context 'with AGFS management information report v2' do
        let(:report_type) { 'agfs_management_information_v2' }
        let(:generator) { Stats::ManagementInformation::DailyReportGenerator }

        it_behaves_like 'a successful report generator caller' do
          let(:args) { { report_type: 'agfs_management_information_v2', scheme: :agfs } }
        end
      end

      context 'with LGFS management information report v2' do
        let(:report_type) { 'lgfs_management_information_v2' }
        let(:generator) { Stats::ManagementInformation::DailyReportGenerator }

        it_behaves_like 'a successful report generator caller' do
          let(:args) { { report_type: 'lgfs_management_information_v2', scheme: :lgfs } }
        end
      end

      context 'with AGFS management information statistics report' do
        subject(:call) { described_class.call(report_type:, start_at: Time.zone.today) }

        let(:report_type) { 'agfs_management_information_statistics' }
        let(:generator) { Stats::ManagementInformation::DailyReportCountGenerator }

        it_behaves_like 'a successful report generator caller' do
          let(:args) do
            { report_type: 'agfs_management_information_statistics',
              query_set: instance_of(Stats::ManagementInformation::AGFSQuerySet),
              start_at: Time.zone.today,
              duration: 1.month - 1.day }
          end
        end
      end

      context 'with LGFS management information statistics report' do
        subject(:call) { described_class.call(report_type:, start_at: Time.zone.today) }

        let(:report_type) { 'lgfs_management_information_statistics' }
        let(:generator) { Stats::ManagementInformation::DailyReportCountGenerator }

        it_behaves_like 'a successful report generator caller' do
          let(:args) do
            { report_type: 'lgfs_management_information_statistics',
              query_set: instance_of(Stats::ManagementInformation::LGFSQuerySet),
              start_at: Time.zone.today,
              duration: 1.month - 1.day }
          end
        end
      end
    end

    context 'with an unexpected error' do
      let(:report_type) { 'management_information' }

      before do
        allow(Stats::ManagementInformationGenerator).to receive(:call).and_raise(StandardError)
      end

      it 'marks report as errored' do
        expect {
          call rescue nil
        }.to change { Stats::StatsReport.where(report_name: report_type).errored.count }.from(0).to(1)
      end

      it 'raises the error' do
        expect { call }.to raise_error(StandardError)
      end

      context 'with notifications enabled' do
        before do
          allow(Settings).to receive(:notify_report_errors).and_return(true)
          allow(ActiveSupport::Notifications).to receive(:instrument)
          call rescue nil
        end

        it 'sends an error notification with expected args' do
          record = Stats::StatsReport.where(report_name: report_type).errored.first
          args = ['call_failed.stats_report', { id: record.id, name: report_type, error: instance_of(StandardError) }]
          expect(ActiveSupport::Notifications).to have_received(:instrument).with(*args)
        end
      end

      context 'with notifications disabled' do
        before do
          allow(Settings).to receive(:notify_report_errors).and_return(false)
          allow(ActiveSupport::Notifications).to receive(:instrument)
        end

        it 'does not send an error notification' do
          call rescue nil

          # Only check that your app-specific error event was not triggered
          expect(ActiveSupport::Notifications).not_to have_received(:instrument).with(
            'call_failed.stats_report', anything
          )
        end
      end
    end
  end
end
