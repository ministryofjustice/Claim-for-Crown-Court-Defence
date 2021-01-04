require 'rails_helper'

describe Reports::PerformancePlatform::QuarterlyVolume, :currency_vcr do
  subject(:report) { described_class.new(date) }

  let(:valid_report_date) { Date.new(2018, 10, 1) }
  let(:date) { valid_report_date }
  let(:client) do
    Aws::CostExplorer::Client.new(
      region: 'us-east-1',
      stub_responses:
        {
          get_cost_and_usage: cost_response,
          get_dimension_values: dimension_response
        }
    )
  end

  let(:dimension_response) do
    Aws::CostExplorer::Types::GetDimensionValuesResponse.new(
      return_size: 1,
      total_size: 1,
      dimension_values: [
        Aws::CostExplorer::Types::DimensionValuesWithAttributes.new(
          value: '000000000001',
          attributes: { 'description' => 'Linked Account name' }
        )
      ]
    )
  end

  let(:cost_response) do
    Aws::CostExplorer::Types::GetCostAndUsageResponse.new(
      results_by_time: [
        Aws::CostExplorer::Types::ResultByTime.new(
          time_period: Aws::CostExplorer::Types::DateInterval.new(
            start: '2018-10-01',
            end: '2018-11-01'
          ),
          total: {
            'UnblendedCost' => Aws::CostExplorer::Types::MetricValue.new(
              amount: '2633.102095783',
              unit: 'USD'
            )
          }
        )
      ]
    )
  end

  before { allow(Aws::CostExplorer::Client).to receive(:new).and_return client }

  describe 'initializing' do
    context 'when the date is not the start of a quarter' do
      let(:date) { Date.new(2018, 10, 2) }

      it { expect { report }.to raise_error('Report must start on a quarter') }
    end

    context 'when the date is in the future' do
      let(:date) { Date.new(2019, 1, 1) }

      it do
        travel_to(Date.new(2018, 12, 31)) do
          expect { report }.to raise_error('Report cannot be in the future')
        end
      end
    end

    context 'when the date is valid' do
      it { is_expected.to be_truthy }
      it { expect(report.ready_to_send).to be false }
    end
  end

  describe '#populate_data' do
    subject(:populate_data) { report.populate_data }
    let(:total_cost) { 1234.45 }
    let(:claim_count) { 1235 }

    context 'when the aws values are accepted' do
      context 'when the data is fine' do
        it { expect(populate_data).to be_truthy }
        it { expect { populate_data }.to change { report.ready_to_send }.from(false).to(true) }
      end

      context 'when a collation error occurs' do
        before { allow(report).to receive(:inputs_numeric?).and_raise(StandardError) }

        it { expect(report.ready_to_send).to be false }
        it { expect { populate_data }.not_to change { report.ready_to_send }.from(false) }
      end
    end
  end

  describe '#publish!' do
    subject(:publish) { report.publish! }

    before do
      report.populate_data
      stub_request(:post, %r{\Ahttps://www.performance.service.gov.uk/data/.*\z}).to_return(status: 200, body: '', headers: {})
    end

    it { is_expected.to be_truthy }
  end
end
