require 'rails_helper'

RSpec.describe StatsReportGenerationJob do
  subject(:job) { described_class.new }

  describe '#perform' do
    subject(:perform) { job.perform(report_type: 'my_report_type', my_option: 1) }

    before do
      allow(LogStuff).to receive(:info)
      allow(Stats::StatsReportGenerator).to receive(:call).with(any_args)
    end

    it 'calls the stats report generator with the provided report type' do
      perform
      expect(Stats::StatsReportGenerator).to have_received(:call).with(report_type: 'my_report_type', my_option: 1)
    end

    it 'log start and end' do
      perform
      expect(LogStuff)
        .to have_received(:info)
        .with(class: described_class.to_s, action: 'perform', report_type: 'my_report_type')
        .twice
    end
  end
end
