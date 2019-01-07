require 'rails_helper'

describe Reports::PerformancePlatform::QuarterlyVolume do
  subject(:report) { described_class.new(date) }

  let(:valid_report_date) { Date.new(2018, 10, 1) }
  let(:date) { valid_report_date }

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
    subject(:populate_data) { report.populate_data(total_cost) }
    let(:total_cost) { 1234.45 }

    context 'when the total_cost submitted is valid' do
      context 'when the data is fine' do
        it { expect(populate_data).to be_truthy }
        it { expect { populate_data }.to change { report.ready_to_send }.from(false).to(true) }
      end

      context 'when a collation error occurs' do
        before { allow(report).to receive(:count_digital_claims).and_raise(StandardError)}

        it { expect(report.ready_to_send).to be false }
        it { expect { populate_data }.not_to change { report.ready_to_send }.from(false) }
      end
    end

    context 'when the total_cost submitted is invalid' do
      before { allow(report).to receive(:count_digital_claims).and_raise(StandardError)}
      let(:total_cost) { '47 pounds' }

      it { expect { populate_data }.to raise_error('Total cost cannot be parsed as a numeric value')}
    end
  end

  describe '#publish!' do
    subject(:publish) { report.publish! }

    before do
      report.populate_data(1234)
      stub_request(:post, %r{\Ahttps://www.performance.service.gov.uk/data/.*\z}).to_return(status: 200, body: "", headers: {})
    end

    it { is_expected.to be_truthy }
  end
end
