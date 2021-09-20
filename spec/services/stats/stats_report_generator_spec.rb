require 'rails_helper'

RSpec.describe Stats::StatsReportGenerator, type: :service do
  describe '.call' do
    subject(:call) { described_class.call(report_type) }

    context 'with an invalid report type' do
      let(:report_type) { 'some-report-type' }

      before { allow(Settings).to receive(:notify_report_errors).and_return(false) }

      it 'raises an invalid report type error' do
        expect { call }.to raise_error(Stats::StatsReportGenerator::InvalidReportType)
      end

      it 'does not create a new report' do
        expect { call rescue nil }.not_to change { Stats::StatsReport.count }.from(0)
      end
    end

    context 'with a valid report type that is already in progress' do
      let(:report_type) { 'management_information' }

      before { Stats::StatsReport.create(report_name: report_type, status: 'started') }

      it 'does not create a new report' do
        expect { call }.not_to change { Stats::StatsReport.count }.from(1)
      end
    end

    context 'with a valid report type that is not already in progress' do
      let(:mocked_result) { Stats::Result.new('some new content', 'csv') }

      context 'with generic report type' do
        let(:report_type) { 'submitted_claims' }

        before { allow(Stats::ReportGenerator).to receive(:call).and_return(mocked_result) }

        it 'calls report generator' do
          call
          expect(Stats::ReportGenerator).to have_received(:call)
        end

        it 'marks report as completed' do
          expect { call }.to change(Stats::StatsReport.where(report_name: report_type).completed, :count).by 1
        end

        it 'generates report content' do
          call
          record = Stats::StatsReport.where(report_name: report_type).completed.last
          file_path = ActiveStorage::Blob.service.path_for(record.document.blob.key)
          expect(File.open(file_path).read).to eq('some new content')
        end
      end

      context 'with management information report' do
        let(:report_type) { 'management_information' }

        before { allow(Stats::ManagementInformationGenerator).to receive(:call).and_return(mocked_result) }

        it 'calls management information generator with no claim scope' do
          call
          expect(Stats::ManagementInformationGenerator).to have_received(:call).with(hash_excluding(:claim_scope))
        end

        it 'marks report as completed' do
          expect { call }.to change(Stats::StatsReport.where(report_name: report_type).completed, :count).by 1
        end

        it 'generates report content' do
          call
          record = Stats::StatsReport.where(report_name: report_type).completed.last
          file_path = ActiveStorage::Blob.service.path_for(record.document.blob.key)
          expect(File.open(file_path).read).to eq('some new content')
        end
      end

      context 'with AGFS management information report' do
        let(:report_type) { 'agfs_management_information' }

        before { allow(Stats::ManagementInformationGenerator).to receive(:call).and_return(mocked_result) }

        it 'calls management information generator with agfs scope' do
          call
          expect(Stats::ManagementInformationGenerator).to have_received(:call).with({ claim_scope: :agfs })
        end
      end

      context 'with LGFS management information report' do
        let(:report_type) { 'lgfs_management_information' }

        before { allow(Stats::ManagementInformationGenerator).to receive(:call).and_return(mocked_result) }

        it 'calls management information generator with lgfs scope' do
          call
          expect(Stats::ManagementInformationGenerator).to have_received(:call).with({ claim_scope: :lgfs })
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
          args = ['call_failed.stats_report', id: record.id, name: report_type, error: instance_of(StandardError)]
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
          expect(ActiveSupport::Notifications).not_to have_received(:instrument)
        end
      end
    end
  end
end
