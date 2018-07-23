require 'rails_helper'

RSpec.describe Stats::StatsReportGenerator, type: :service do
  describe '.call' do
    context 'when the report type is not valid' do
      let(:report_type) { 'some-report-type' }

      it 'raises an invalid report type error' do
        expect { described_class.call(report_type) }.to raise_error(Stats::StatsReportGenerator::InvalidReportType)
      end

      it 'does not create a new report' do
        expect {
          described_class.call(report_type) rescue nil
        }.not_to change { Stats::StatsReport.count }.from(0)
      end
    end

    context 'when there is already a report of that type in progress' do
      let(:report_type) { 'management_information' }
      let!(:report) { Stats::StatsReport.create(report_name: report_type, status: 'started', report: 'some content') }

      it 'does not create a new report' do
        expect {
          described_class.call(report_type)
        }.not_to change { Stats::StatsReport.count }.from(1)
      end
    end

    context 'when there is no report of that type in progress' do
      let(:report_type) { 'management_information' }
      let!(:report) { Stats::StatsReport.create(report_name: report_type, status: 'completed', report: 'some content') }
      let(:mocked_result) { Stats::Result.new('some new content', 'csv') }

      it 'creates a new report marked as completed with the generated content' do
        expect(Stats::ManagementInformationGenerator).to receive(:call).and_return(mocked_result)
        expect {
          described_class.call(report_type)
        }.to change { Stats::StatsReport.where(report_name: report_type).completed.count }.from(1).to(2)
        new_record = Stats::StatsReport.where(report_name: report_type).completed.last
        expect(new_record.document).to be_kind_of(Paperclip::Attachment)
        expect(open(new_record.document.path).read).to eq('some new content')
      end

      context 'but an error happens during the generation of the report' do
        before do
          expect(Stats::ManagementInformationGenerator).to receive(:call).and_raise(StandardError)
        end

        it 'raises the error' do
          expect { described_class.call(report_type) }.to raise_error(StandardError)
        end

        it 'creates a new report marked as errored' do
          expect {
            described_class.call(report_type) rescue nil
          }.to change { Stats::StatsReport.where(report_name: report_type).errored.count }.from(0).to(1)
        end

        context 'and when the error notifications are enabled' do
          before do
            allow(Settings).to receive(:notify_report_errors).and_return(true)
          end

          it 'sends an error notification' do
            allow(ActiveSupport::Notifications).to receive(:instrument)
            described_class.call(report_type) rescue nil
            record = Stats::StatsReport.where(report_name: report_type).errored.first
            args = ['call_failed.stats_report', id: record.id, name: report_type, error: instance_of(StandardError)]
            expect(ActiveSupport::Notifications).to have_received(:instrument).with(*args)
          end
        end

        context 'and when the error notifications are disabled' do
          before do
            allow(Settings).to receive(:notify_report_errors).and_return(false)
          end

          it 'does not sends an error notification' do
            expect(ActiveSupport::Notifications).not_to receive(:instrument)
            described_class.call(report_type) rescue nil
          end
        end
      end
    end
  end
end
