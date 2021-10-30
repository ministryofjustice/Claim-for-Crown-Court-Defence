require 'rails_helper'

RSpec.describe StatsReportGenerationJob, type: :job do
  subject(:job) { described_class.new }

  describe '#perform' do
    subject(:perform) { job.perform('any_old_report_name', my_option: 1) }

    before do
      allow(Stats::StatsReportGenerator).to receive(:call).with(instance_of(String), instance_of(Hash))
    end

    it 'calls the stats report generator with the provided report type' do
      perform
      expect(Stats::StatsReportGenerator).to have_received(:call).with('any_old_report_name', my_option: 1)
    end
  end
end
