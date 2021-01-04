require 'rails_helper'

RSpec.describe HeartbeatController, type: :controller do
  describe 'ping and heartbeat do not force ssl' do
    before do
      allow(Rails).to receive(:env).and_return('production'.inquiry)
    end

    after do
      expect(response.status).not_to eq(301)
    end

    it 'ping endpoint' do
      get :ping
    end

    it 'healthcheck endpoint' do
      get :healthcheck
    end
  end

  describe '#ping' do
    context 'when environment variables not set' do
      before do
        ENV['VERSION_NUMBER']   = nil
        ENV['BUILD_DATE']       = nil
        ENV['COMMIT_ID']        = nil
        ENV['BUILD_TAG']        = nil
        ENV['APP_BRANCH']       = nil

        get :ping
      end

      it 'returns "Not Available"' do
        expect(JSON.parse(response.body).values).to be_all('Not Available')
      end
    end

    context 'when environment variables set' do
      let(:expected_json) do
        {
          'version_number' => '123',
          'build_date' => '20150721',
          'commit_id' => 'afb12cb3',
          'build_tag' => 'test',
          'app_branch' => 'test_branch'
        }
      end

      before do
        ENV['VERSION_NUMBER']   = '123'
        ENV['BUILD_DATE']       = '20150721'
        ENV['COMMIT_ID']        = 'afb12cb3'
        ENV['BUILD_TAG']        = 'test'
        ENV['APP_BRANCH']       = 'test_branch'

        get :ping
      end

      it 'returns JSON with app information' do
        expect(JSON.parse(response.body)).to eq(expected_json)
      end
    end
  end

  describe '#healthcheck' do
    before do
      allow(Sidekiq::ProcessSet).to receive(:new).and_return(instance_double(Sidekiq::ProcessSet, size: 1))
      allow(Sidekiq::RetrySet).to receive(:new).and_return(instance_double(Sidekiq::RetrySet, size: 0))
      allow(Sidekiq::DeadSet).to receive(:new).and_return(instance_double(Sidekiq::DeadSet, size: 0))
      connection = double('connection')
      allow(connection).to receive(:info).and_return({ redis_version: '5.0.0' })
      allow(Sidekiq).to receive(:redis).and_yield(connection)
    end

    context 'when failed Sidekiq jobs exist' do
      let(:failed_job_healthcheck) do
        {
          checks: { database: true, redis: true, sidekiq: true, sidekiq_queue: false, num_claims: 0 }
        }.to_json
      end

      context 'dead set exists' do
        before do
          allow(Sidekiq::DeadSet).to receive(:new).and_return(instance_double(Sidekiq::DeadSet, size: 1))
          get :healthcheck
        end

        it 'returns ok http status' do
          expect(response).to have_http_status :ok
        end

        it 'returns the expected response report' do
          expect(response.body).to eq(failed_job_healthcheck)
        end
      end

      context 'retry set exists' do
        before do
          allow(Sidekiq::RetrySet).to receive(:new).and_return(instance_double(Sidekiq::RetrySet, size: 1))
          get :healthcheck
        end

        it 'returns ok http status' do
          expect(response).to have_http_status :ok
        end

        it 'returns the expected response report' do
          expect(response.body).to eq(failed_job_healthcheck)
        end
      end
    end

    context 'when an infrastructure problem exists' do
      before do
        allow(ActiveRecord::Base.connection).to receive(:active?).and_raise(PG::ConnectionBad)
        allow(Sidekiq::ProcessSet).to receive(:new).and_return(instance_double(Sidekiq::ProcessSet, size: 0))

        connection = double('connection')
        allow(connection).to receive(:info).and_raise(Redis::CannotConnectError)
        allow(Sidekiq).to receive(:redis).and_yield(connection)

        get :healthcheck
      end

      let(:failed_healthcheck) do
        {
          checks: { database: false, redis: false, sidekiq: false, sidekiq_queue: true, num_claims: 0 }
        }.to_json
      end

      it 'returns status bad gateway' do
        expect(response).to have_http_status :bad_gateway
      end

      it 'returns the expected response report' do
        expect(response.body).to eq(failed_healthcheck)
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
          checks: { database: true, redis: true, sidekiq: true, sidekiq_queue: true, num_claims: 0 }
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
