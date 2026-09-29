require 'rails_helper'

RSpec.describe HealthCheck do
  subject(:health_check) { described_class.new }

  before do
    allow(Sidekiq::ProcessSet).to receive(:new).and_return(instance_double(Sidekiq::ProcessSet, size: 1))
    allow(Sidekiq::RetrySet).to receive(:new).and_return(instance_double(Sidekiq::RetrySet, size: 0))
    allow(Sidekiq::DeadSet).to receive(:new).and_return(instance_double(Sidekiq::DeadSet, size: 0))

    connection = instance_double(Redis, info: { redis_version: '5.0.0' })
    allow(Sidekiq).to receive(:redis).and_yield(connection)
  end

  describe '#checks' do
    subject(:checks) { health_check.checks }

    let(:expected_checks) do
      { database: true, redis: true, sidekiq: true, sidekiq_queue: true, num_claims: Claim::BaseClaim.count }
    end

    it 'returns the status of each dependency plus the number of claims' do
      expect(checks).to eq(expected_checks)
    end
  end

  describe '#healthy?' do
    context 'when all checks pass, except the sidekiq queue' do
      before do
        allow(Sidekiq::DeadSet).to receive(:new).and_return(instance_double(Sidekiq::DeadSet, size: 1))
      end

      it { expect(health_check.healthy?).to be true }
    end

    context 'when the database is unreachable' do
      before { allow(ActiveRecord::Base.connection).to receive(:select_value).and_raise(PG::ConnectionBad) }

      it { expect(health_check.healthy?).to be false }
    end
  end

  describe 'claim count' do
    subject(:num_claims) { health_check.checks[:num_claims] }

    context 'when the database is unreachable' do
      before do
        allow(ActiveRecord::Base.connection).to receive(:select_value).and_raise(PG::ConnectionBad)
        allow(Claim::BaseClaim).to receive(:count)
      end

      it { is_expected.to be_nil }

      it 'does not attempt to count claims' do
        num_claims
        expect(Claim::BaseClaim).not_to have_received(:count)
      end
    end

    context 'when counting claims fails' do
      before { allow(Claim::BaseClaim).to receive(:count).and_raise(ActiveRecord::StatementInvalid) }

      it { is_expected.to be_nil }
      it { expect(health_check.healthy?).to be false }
    end
  end
end
