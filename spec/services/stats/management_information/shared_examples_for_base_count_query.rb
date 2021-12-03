# frozen_string_literal: true

RSpec.shared_examples 'a base count query' do
  describe '.call' do
    subject(:call) { described_class.call(kwargs) }

    let(:kwargs) { { day: Time.zone.today, date_column_filter: :bar } }

    let(:instance) { instance_double(described_class) }
    let(:result) { instance_double(PG::Result) }

    before do
      allow(described_class).to receive(:new).with(any_args).and_return(instance)
      allow(instance).to receive(:call).and_return(result)
    end

    it 'sends \'new\' with arguments' do
      call
      expect(described_class).to have_received(:new).with(hash_including(:day, :date_column_filter))
    end

    it 'sends \'call\' to instance of class' do
      call
      expect(instance).to have_received(:call)
    end
  end

  describe '#call' do
    subject(:call) { described_class.new(kwargs).call }

    let(:day) { Time.zone.today.iso8601 }

    context 'with valid day and date_column_filter' do
      let(:kwargs) { { day: day, date_column_filter: :originally_submitted_at } }

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

    context 'with day as valid date string' do
      let(:kwargs) { { day: '2021-01-01', date_column_filter: :originally_submitted_at } }

      it { expect { call }.not_to raise_error }
    end

    context 'with day as Date object' do
      let(:kwargs) { { day: Date.parse('2021-01-01'), date_column_filter: :originally_submitted_at } }

      it { expect { call }.not_to raise_error }
    end

    context 'with day as invalid date string' do
      let(:kwargs) { { day: '2021-13-01', date_column_filter: :originally_submitted_at } }

      it { expect { call }.to raise_error Date::Error, /invalid date/ }
    end

    context 'without day key' do
      let(:kwargs) { { date_column_filter: :originally_submitted_at } }

      it { expect { call }.to raise_error ArgumentError, 'missing keyword: :day' }
    end

    context 'without date_column_filter' do
      let(:kwargs) { { day: Time.zone.today.iso8601 } }

      it { expect { call }.to raise_error ArgumentError, /missing keyword/ }
    end

    context 'when trying to inject SQL' do
      let(:kwargs) do
        { day: day,
          date_column_filter: 'originally_submitted_at; (select PG_SLEEP(15))' }
      end

      it { expect { call }.to raise_error ActiveRecord::StatementInvalid }
    end
  end
end

RSpec.shared_examples 'an originally_submitted_at filterable query' do
  describe '#call' do
    subject(:result) { described_class.new(kwargs).call }

    let(:kwargs) { { day: day, date_column_filter: :originally_submitted_at } }

    before { claim }

    context 'with submissions on day' do
      let(:day) { Time.zone.today.iso8601 }

      it { expect(result.first['count']).to eq(1) }
    end

    context 'without submissions on day' do
      let(:day) { 1.day.ago.iso8601 }

      it { expect(result.first['count']).to eq(0) }
    end
  end
end

RSpec.shared_examples 'a completed_at filterable query' do
  describe '#call' do
    subject(:result) { described_class.new(kwargs).call }

    let(:kwargs) { { day: day, date_column_filter: :completed_at } }

    before { claim }

    context 'with completions on day' do
      let(:day) { Time.zone.today.iso8601 }

      it { expect(result.first['count']).to eq(1) }
    end

    context 'without completions on day' do
      let(:day) { 1.day.ago.iso8601 }

      it { expect(result.first['count']).to eq(0) }
    end
  end
end
