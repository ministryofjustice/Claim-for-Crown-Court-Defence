# frozen_string_literal: true

RSpec.describe Stats::ManagementInformation::DailyReportCountGenerator do
  describe '.call' do
    subject(:call) { described_class.call(kwargs) }

    let(:kwargs) { { day: Date.current, scheme: 'lgfs' } }

    let(:instance) { instance_double(described_class) }
    let(:result) { instance_double(Stats::Result) }

    before do
      allow(described_class).to receive(:new).with(any_args).and_return(instance)
      allow(instance).to receive(:call).and_return(result)
    end

    it 'sends \'new\' with arguments' do
      call
      expect(described_class).to have_received(:new).with(hash_including(:day, :scheme))
    end

    it 'sends \'call\' to instance of class' do
      call
      expect(instance).to have_received(:call)
    end
  end

  describe '#call' do
    subject(:call) { described_class.new(kwargs).call }

    let(:expected_headers) do
      %w[Name
         Saturday
         Sunday
         Monday
         Tuesday
         Wednesday
         Thursday
         Friday]
    end

    context 'without scheme' do
      let(:kwargs) { { day: Date.current } }

      it { expect { call }.to raise_error ArgumentError, 'scheme must be "agfs" or "lgfs"' }
    end

    context 'with invalid scheme' do
      let(:kwargs) { { day: Date.current, scheme: 'not_a_scheme' } }

      it { expect { call }.to raise_error ArgumentError, 'scheme must be "agfs" or "lgfs"' }
    end

    context 'without day' do
      let(:kwargs) { { scheme: 'agfs' } }

      it { expect { call }.to raise_error ArgumentError, 'day must be provided' }
    end

    context 'with scheme and day' do
      subject(:result) { described_class.new(kwargs).call }

      let(:kwargs) { { day: Date.current, scheme: 'agfs' } }

      it 'returns a Stats::Result object' do
        is_expected.to be_instance_of(Stats::Result)
      end

      it 'returns Stats::Result object with content' do
        expect(result.content).to be_truthy
      end

      # TODO: amend class and spec to use day as start of a date range (hardcode to a month or injectable)
      xit 'csv has expected headers' do
        csv = CSV.parse(result.content, headers: true)
        expect(csv.headers).to match_array(expected_headers)
      end
    end
  end
end
