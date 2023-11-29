RSpec.describe Schedule::ReportGeneration do
  subject(:generator_task) { described_class.new }

  describe '#perform' do
    subject(:perform) { generator_task.perform(report_type) }

    let(:report_type) { :test_report_type }

    before do
      allow(Stats::StatsReportGenerator).to receive(:call)
    end

    it do
      perform
      expect(Stats::StatsReportGenerator).to have_received(:call).with(report_type:)
    end
  end
end
