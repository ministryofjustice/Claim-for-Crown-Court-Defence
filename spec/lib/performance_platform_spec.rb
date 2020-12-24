require 'rails_helper'

RSpec.describe PerformancePlatform do
  subject(:perf_platform) { described_class }

  describe '.report' do
    subject(:report) { described_class.report(report_name) }

    before do
      expected_yaml = { 'reports' => { 'transactions_by_channel' => { 'type' => 'test-transactions-by-channel', 'period' => 'weekly', 'fields' => [:channel, :count], 'token' => nil } } }
      allow_any_instance_of(PerformancePlatform::Reports).to receive(:yaml_file).and_return(expected_yaml)
    end

    context 'when passed a report name that is present in the yaml file' do
      let(:report_name) { 'transactions_by_channel' }

      it { is_expected.to be_a PerformancePlatform::Submission }
    end

    context 'when passed a report name that is not present in the yaml file' do
      let(:report_name) { 'non-existent-report' }

      it { expect { report }.to raise_error('non-existent-report is not present in config/performance_platform.yml') }
    end
  end

  describe '.reset' do
    let(:root_url) { 'https://new.pi/endpoint' }

    before do
      described_class.configure do |config|
        config.root_url = root_url
      end
    end

    it 'resets the configured host' do
      expect(described_class.configuration.root_url).to eql root_url
      described_class.reset
      expect(described_class.configuration.root_url).to eql 'https://www.performance.service.gov.uk/data'
    end
  end
end
