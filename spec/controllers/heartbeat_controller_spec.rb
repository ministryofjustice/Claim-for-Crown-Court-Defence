require 'rails_helper'

RSpec.describe HeartbeatController, type: :controller do
  describe '#ping' do
    context 'when environment variables not set' do
      before do
        ENV['VERSION_NUMBER']   = nil
        ENV['BUILD_DATE']       = nil
        ENV['COMMIT_ID']        = nil
        ENV['BUILD_TAG']        = nil

        get :ping
      end

      it 'returns "Not Available"' do
        expect(JSON.parse(response.body).values).to eq(['Not Available'] * 4)
      end
    end

    context 'when environment variables set' do
      let(:expected_json) do
        {
          'version_number'  => '123',
          'build_date'      => '20150721',
          'commit_id'       => 'afb12cb3',
          'build_tag'       => 'test'
        }
      end

      before do
        ENV['VERSION_NUMBER']   = '123'
        ENV['BUILD_DATE']       = '20150721'
        ENV['COMMIT_ID']        = 'afb12cb3'
        ENV['BUILD_TAG']        = 'test'

        get :ping
      end

      it 'returns JSON with app information' do
        expect(JSON.parse(response.body)).to eq(expected_json)
      end
    end
  end

  describe '#healthcheck' do
    context 'when a problem exists' do
      before do
        allow(ActiveRecord::Base.connection).to receive(:active?).and_raise(PG::ConnectionBad)

        connection = double('connection')
        allow(connection).to receive(:info).and_raise(Redis::CannotConnectError)
        allow(Sidekiq).to receive(:redis).and_yield(connection)

        get :healthcheck
      end

      let(:expected_response) do
        {
          checks: { database: false, redis: false }
        }.to_json
      end

      it 'returns status bad gateway' do
        expect(response.status).to eq(502)
      end

      it 'returns the expected response report' do
        expect(response.body).to eq(expected_response)
      end
    end

    context 'when everything is ok' do
      before do
        allow(ActiveRecord::Base.connection).to receive(:active?).and_return(true)

        connection = double('connection', info: {})
        allow(Sidekiq).to receive(:redis).and_yield(connection)

        get :healthcheck
      end

      let(:expected_response) do
        {
          checks: { database: true, redis: true }
        }.to_json
      end

      it 'returns HTTP success' do
        get :healthcheck
        expect(response.status).to eq(200)
      end

      it 'returns the expected response report' do
        get :healthcheck
        expect(response.body).to eq(expected_response)
      end
    end
  end
end
