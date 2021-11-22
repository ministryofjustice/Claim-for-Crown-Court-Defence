# frozen_string_literal: true

RSpec.shared_examples 'a base MI report query' do
  describe '.call' do
    subject(:call) { described_class.call(kwargs) }

    let(:kwargs) { { scheme: 'whatever', day: Time.zone.today } }

    let(:instance) { instance_double(described_class) }
    let(:result) { instance_double(PG::Result) }

    before do
      allow(described_class).to receive(:new).with(any_args).and_return(instance)
      allow(instance).to receive(:call).and_return(result)
    end

    it 'sends \'new\' with arguments' do
      call
      expect(described_class).to have_received(:new).with(hash_including(:scheme, :day))
    end

    it 'sends \'call\' to instance of class' do
      call
      expect(instance).to have_received(:call)
    end
  end

  describe '#call' do
    subject(:call) { described_class.new(kwargs).call }

    let(:day) { Time.zone.today.iso8601 }

    context 'with valid scheme and day in acceptable format' do
      let(:kwargs) { { scheme: 'agfs', day: day } }

      it 'returned object behaves like array' do
        is_expected.to respond_to(:[])
      end

      it 'returned object has only one element' do
        expect(call.count).to be(1)
      end

      it 'first returned object has a "count" key' do
        expect(call.first.key?('count')).to be true
      end

      it 'first returned object "count" is integer' do
        expect(call.first['count']).to be_an(Integer)
      end
    end

    context 'without scheme' do
      let(:kwargs) { { day: day } }

      it { expect { call }.to raise_error ArgumentError, 'scheme must be "agfs" or "lgfs"' }
    end

    context 'with invalid scheme' do
      let(:kwargs) { { scheme: 'not_a_scheme', day: day } }

      it { expect { call }.to raise_error ArgumentError, 'scheme must be "agfs" or "lgfs"' }
    end

    context 'without day' do
      let(:kwargs) { { scheme: 'agfs' } }

      it { expect { call }.to raise_error ArgumentError, 'day must be provided' }
    end

    context 'with day in unusable format' do
      let(:kwargs) { { scheme: 'agfs', day: Time.zone.today } }

      it { expect { call }.to raise_error ActiveRecord::StatementInvalid, %r{date/time field value} }
    end

    context 'when trying to inject SQL via day' do
      let(:kwargs) { { scheme: 'agfs', day: "\'#{Time.zone.today.iso8601}\'; (select PG_SLEEP(15)" } }

      it { expect { call }.to raise_error ActiveRecord::StatementInvalid }
    end
  end
end

RSpec.describe Stats::ManagementInformation::Agfs::IntakeFixedFeeQuery do
  it_behaves_like 'a base MI report query'

  describe '#call' do
    subject(:result) { described_class.new(kwargs).call }

    let(:kwargs) { { scheme: 'agfs', day: Time.zone.today.iso8601 } }

    before do
      create(:advocate_final_claim,
             :submitted,
             :with_fixed_fee_case,
             fixed_fees: [build(:fixed_fee, :fxase_fee, rate: 0.50)])
    end

    it 'returns expected count' do
      expect(result.first['count']).to be(1)
    end
  end
end
