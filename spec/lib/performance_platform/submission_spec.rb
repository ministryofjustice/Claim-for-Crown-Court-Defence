require 'rails_helper'

describe PerformancePlatform::Submission do
  subject(:submission) { described_class.new(report) }

  let(:service) { 'cccd' }
  let(:report) { { type: "test-transactions-by-channel", period: "weekly", fields: [:channel, :count], token: 'fake-token' } }

  it { is_expected.to respond_to :add_data_set }
  it { is_expected.to respond_to :send_data! }
  before do
    stub_request(:post, %r{\Ahttps://www.performance.service.gov.uk/data/.*\z}).to_return(status: 200, body: "", headers: {})
  end
  describe '#send_data!' do
    subject(:send_data!) { submission.send_data! }

    context 'when no data has been defined' do
      it 'raises an error' do
        expect{ subject }.to raise_error(RuntimeError, 'Unable to send without payload')
      end
    end

    context 'when data_set has been filled' do
      before do
        submission.add_data_set(Date.new(2018,8,13), channel: 'Paper', count: 0)
        subject
      end

      it 'hits the performance platform' do
        expect(a_request(:post, /\Ahttps:\/\/www.performance.service.gov.uk\/data\/.*\z/)).to have_been_made.times(1)
      end

      it { is_expected.to be_truthy } 
    end
  end
end
