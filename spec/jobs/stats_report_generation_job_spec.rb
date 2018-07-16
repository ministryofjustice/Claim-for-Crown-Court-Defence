require 'rails_helper'

RSpec.describe StatsReportGenerationJob, type: :job do
  describe '#perform' do
    let(:report_type) { 'provisional_assessment' }
    let(:result) { double(:generator_result) }

    subject(:job) { described_class.new }

    it 'calls the stats report generator with the provided report type' do
      expect(Stats::StatsReportGenerator).to receive(:call).with(report_type).and_return(result)
      expect(job.perform(report_type)).to eq(result)
    end
  end
end
