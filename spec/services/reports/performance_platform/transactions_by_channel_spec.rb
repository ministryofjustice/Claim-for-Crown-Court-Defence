require 'rails_helper'

describe Reports::PerformancePlatform::TransactionsByChannel do
  subject(:report) { described_class.new(date) }

  let(:monday) { Date.new(2018, 12, 24) }
  let(:tuesday) { Date.new(2018, 12, 25) }

  describe 'initializing' do
    context 'when the date is not a Monday' do
      let(:date) { Date.new(2018, 12, 25) }

      it { expect { report }.to raise_error('Report must start on a Monday') }
    end

    context 'when the date is within the last 7 days' do
      let(:date) { monday }

      it do
        travel_to(tuesday) do
          expect { report }.to raise_error('Report cannot be in the current week')
        end
      end
    end

    context 'when the date is in the future' do
      let(:date) { Date.new(2018, 12, 31) }

      it do
        travel_to(tuesday) do
          expect { report }.to raise_error('Report cannot be in the future')
        end
      end
    end

    context 'when the date is valid' do
      let(:date) { Date.new(2018, 12, 17) }

      it { is_expected.to be_truthy }
      it { expect(report.ready_to_send).to be false }
    end
  end

  describe '#populate_data' do
    subject(:populate_data) { report.populate_data }
    let(:date) { Date.new(2018, 12, 17) }

    context 'when the data is fine' do
      it { expect(populate_data).to be_truthy }
      it { expect { populate_data }.to change { report.ready_to_send }.from(false).to(true) }
    end

    context 'when a collation error occurs' do
      before { allow(report).to receive(:count_digital_claims).and_raise(StandardError) }

      it { expect(populate_data).to be_falsey }
      it { expect { populate_data }.not_to change { report.ready_to_send }.from(false) }
    end
  end

  describe '#publish!' do
    subject(:publish) { report.publish! }
    let(:date) { Date.new(2018, 12, 17) }

    before do
      report.populate_data
      stub_request(:post, %r{\Ahttps://www.performance.service.gov.uk/data/.*\z}).to_return(status: 200, body: '', headers: {})
    end

    it { is_expected.to be_truthy }
  end
end
