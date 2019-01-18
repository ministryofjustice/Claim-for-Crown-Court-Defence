require 'rails_helper'

describe PerformancePlatform::DataSet do
  subject(:data_set) { described_class.new(params) }

  let(:params) { { _timestamp: time_stamp, service: service, period: period, channel: channel, count: count } }
  let(:time_stamp) { '2018-01-01T00:00:00+00:00' }
  let(:channel) { 'Digital' }
  let(:count) { 1234 }
  let(:period) { 'week' }
  let(:service)  { 'cccd'}


  describe 'initialized' do
    subject(:payload) { data_set.payload }
    describe 'with a channel' do
      let(:expected_result) do
        {
          _id: 'MjAxOC0wMS0wMVQwMDowMDowMCswMDowMC5jY2NkLndlZWsuRGlnaXRhbA==',
          _timestamp: '2018-01-01T00:00:00+00:00',
          service: 'cccd',
          period: 'week',
          channel: 'Digital',
          count: 1234
        }
      end

      it { is_expected.to eql(expected_result) }
    end

    describe 'without a channel' do
      let(:params) { { _timestamp: time_stamp, service: service, period: period, count: count } }

      let(:expected_result) do
        {
          _id: 'MjAxOC0wMS0wMVQwMDowMDowMCswMDowMC5jY2NkLndlZWs=',
          _timestamp: '2018-01-01T00:00:00+00:00',
          service: 'cccd',
          period: 'week',
          count: 1234
        }
      end

      it { is_expected.to eql(expected_result) }
    end

    describe '_id' do
      subject { payload[:_id] }

      it 'can be decoded to match the values' do
        expect(Base64.decode64(subject)).to eq '2018-01-01T00:00:00+00:00.cccd.week.Digital'
      end
    end
  end

end
