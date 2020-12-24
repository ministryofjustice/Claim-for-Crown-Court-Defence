require 'rails_helper'

RSpec.describe PerformancePlatform::Reports do
  subject(:reports) { described_class.new }
  let(:expected_yaml) { { 'reports' => { 'transactions_by_channel' => { 'type' => 'test-transactions-by-channel', 'period' => 'weekly', 'fields' => [:channel, :count], 'token' => nil } } } }

  before do
    allow_any_instance_of(described_class).to receive(:yaml_file).and_return(expected_yaml)
  end

  context 'when the reports file can be processed' do
    it { is_expected.to be_a PerformancePlatform::Reports }
  end

  context 'when the reports file cannot be processed' do
    let(:expected_yaml) { nil }
    it { expect { reports }.to raise_error('config/performance_platform.yml cannot be loaded') }
  end

  describe '.call' do
    subject(:call) { reports.call(report) }

    context 'when passed a report name that is present in the yaml file' do
      let(:report) { 'transactions_by_channel' }

      it { is_expected.to be_a Hash }
    end

    context 'when passed a report name that is not present in the yaml file' do
      let(:report) { 'non-existent-report' }

      it { expect { call }.to raise_error('non-existent-report is not present in config/performance_platform.yml') }
    end
  end
end
