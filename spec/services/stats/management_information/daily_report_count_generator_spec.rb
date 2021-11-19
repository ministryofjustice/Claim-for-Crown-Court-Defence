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

    context 'with valid scheme and day' do
      subject(:result) { described_class.new(kwargs).call }

      let(:kwargs) { { day: start_date, scheme: 'agfs' } }
      let(:start_date) { 1.month.ago.to_date }

      it 'returns a Stats::Result object' do
        is_expected.to be_instance_of(Stats::Result)
      end

      it 'returns Stats::Result object with content' do
        expect(result.content).to be_truthy
      end

      let(:expected_headers) do
        (start_date..(start_date + 1.month)).to_a.map { |d| d.strftime("%d/%m/%Y\n%A") }.prepend('Name')
      end

      it 'generates expected CSV headers' do
        csv = CSV.parse(result.content, headers: true)
        expect(csv.headers).to match_array(expected_headers)
      end
    end

    context 'when AGFS data exists' do
      subject(:result) { described_class.new(kwargs).call }

      let(:kwargs) { { day: start_date, scheme: 'agfs' } }
      let(:start_date) { 1.month.ago.to_date }

      before do
        travel_to(start_date.beginning_of_day) do
          create_list(:advocate_final_claim, 3, :refused, case_type: build(:case_type, :trial))
        end
      end

      let(:rows) { CSV.parse(result.content, headers: true) }

      # DEBUG help. To check SQL being counted
      # you can use;
      # ActiveRecord::Base.connection
      #   .execute("WITH journeys AS (#{journeys_query}) select scheme, case_type_name, journey -> 0 ->> 'to', date_trunc('day', j.originally_submitted_at), j.disk_evidence, j.claim_total::float from journeys j")
      #   .to_a
      #
      it 'has expected counts in the date column' do
        all_counts_for_day = rows[start_date.strftime("%d/%m/%Y\n%A")].map(&:to_i)
        expect(all_counts_for_day).to contain_exactly(3, 0, 0, 0 ,0, 0, 0, 0)
      end

      it 'has expected count at expected row (intake_final_fee) and column (date)' do
        counts = rows.find {|row| row['Name'].eql?('Intake final fee') }
        count = counts[start_date.strftime("%d/%m/%Y\n%A")].to_i
        expect(count).to eq(3)
      end
    end

    context 'with logging' do
      before { allow(LogStuff).to receive(:info) }

      let(:kwargs) { { day: Date.current, scheme: 'lgfs' } }

      it 'logs start and end' do
        call
        expect(LogStuff).to have_received(:info).twice
      end
    end

    context 'when unexpected errors raised' do
      before do
        allow(CSV).to receive(:generate).and_raise(StandardError, 'oops')
        allow(LogStuff).to receive(:error)
      end

      let(:kwargs) { { day: Date.current, scheme: 'lgfs' } }

      it 'uses LogStuff to log error' do
        call
      rescue StandardError
        nil
      ensure
        expect(LogStuff).to have_received(:error).once
      end

      it 're-raises the error' do
        expect { call }.to raise_error(StandardError, 'oops')
      end
    end
  end
end
