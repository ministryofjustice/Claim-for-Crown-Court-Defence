require 'rails_helper'

RSpec.describe StatsReportGenerationJob, type: :job do
  subject(:job) { described_class.new }

  describe '#perform' do
    subject (:perform) { job.perform(report_type) }

    let(:report_type) { 'provisional_assessment' }

    it 'calls the stats report generator with the provided report type' do
      expect(Stats::StatsReportGenerator).to receive(:call).with(report_type)
      perform
    end
  end
end
