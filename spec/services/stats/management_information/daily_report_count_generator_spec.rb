# frozen_string_literal: true

RSpec.describe Stats::ManagementInformation::DailyReportCountGenerator do
  describe '.call' do
    subject(:call) { described_class.call(**kwargs) }

    let(:kwargs) { { query_set: 'foo', start_at: 'bar' } }
    let(:instance) { instance_double(described_class) }
    let(:result) { instance_double(Stats::Result) }

    before do
      allow(described_class).to receive(:new).with(any_args).and_return(instance)
      allow(instance).to receive(:call).and_return(result)
    end

    it 'sends \'new\' with arguments' do
      call
      expect(described_class).to have_received(:new).with(hash_including(:query_set, :start_at))
    end

    it 'sends \'call\' to instance of class' do
      call
      expect(instance).to have_received(:call)
    end
  end

  describe '#call' do
    subject(:call) { described_class.new(**kwargs).call }

    context 'without query_set' do
      let(:kwargs) { { start_at: Date.current } }

      it { expect { call }.to raise_error ArgumentError, 'query set must be provided' }
    end

    context 'without start_at' do
      let(:kwargs) { { query_set: } }
      let(:query_set) { Stats::ManagementInformation::LgfsQuerySet.new }

      it { expect { call }.to raise_error ArgumentError, 'start_at must be provided' }
    end

    context 'with query_set and start_at' do
      subject(:result) { described_class.new(**kwargs).call }

      let(:kwargs) { { query_set:, start_at: start_date } }
      let(:query_set) { Stats::ManagementInformation::LgfsQuerySet.new }
      let(:start_date) { 1.month.ago.to_date }
      let(:duration) { 1.month - 1.day }

      let(:expected_headers) do
        (start_date..(start_date + duration)).to_a.map { |d| d.strftime("%d/%m/%Y\n%A") }.prepend('Name', 'Filter')
      end

      it 'returns a Stats::Result object' do
        is_expected.to be_instance_of(Stats::Result)
      end

      it 'returns Stats::Result object with content' do
        expect(result.content).to be_truthy
      end

      it 'generates expected CSV headers' do
        csv = CSV.parse(result.content, headers: true)
        expect(csv.headers).to match_array(expected_headers)
      end
    end

    context 'with valid scheme, start_at and duration' do
      subject(:result) { described_class.new(**kwargs).call }

      let(:query_set) { Stats::ManagementInformation::LgfsQuerySet.new }
      let(:start_date) { 1.week.ago.to_date }
      let(:duration) { 1.month - 1.day }

      let(:expected_headers) do
        (start_date..(start_date + duration)).to_a.map { |d| d.strftime("%d/%m/%Y\n%A") }.prepend('Name', 'Filter')
      end

      context 'with no duration' do
        let(:kwargs) { { query_set:, start_at: start_date } }

        it 'generates expected CSV headers with default of 1 calendar month duration' do
          csv = CSV.parse(result.content, headers: true)
          expect(csv.headers).to match_array(expected_headers)
        end
      end

      context 'with 1 week duration' do
        let(:kwargs) { { query_set:, start_at: start_date, duration: } }
        let(:duration) { 1.week }

        it 'generates expected CSV headers covering 1 week duration' do
          csv = CSV.parse(result.content, headers: true)
          expect(csv.headers).to match_array(expected_headers)
        end
      end

      context 'with 2 week duration' do
        let(:kwargs) { { query_set:, start_at: start_date, duration: } }
        let(:duration) { 1.week }

        it 'generates expected CSV headers covering 2 week duration' do
          csv = CSV.parse(result.content, headers: true)
          expect(csv.headers).to match_array(expected_headers)
        end
      end
    end

    # DEBUG help: To check SQL being counted
    # you can use;
    # ActiveRecord::Base.connection
    #   .execute("WITH journeys AS (#{journeys_query}) select scheme, case_type_name, journey -> 0 ->> 'to', date_trunc('day', j.originally_submitted_at), j.disk_evidence, j.claim_total::float from journeys j")
    #   .to_a
    #
    context 'when AGFS final claims data exists' do
      subject(:result) { described_class.new(**kwargs).call }

      before do
        travel_to(start_date.beginning_of_day) do
          create_list(:advocate_final_claim, 3, :refused, case_type: build(:case_type, :trial))
        end
      end

      let(:kwargs) { { query_set:, start_at: start_date } }
      let(:query_set) { Stats::ManagementInformation::AGFSQuerySet.new }
      let(:start_date) { 1.month.ago.to_date }
      let(:rows) { CSV.parse(result.content, headers: true) }

      it 'has expected counts in the date column' do
        all_counts_for_start_date = rows[start_date.strftime("%d/%m/%Y\n%A")].map(&:to_i)
        expected_counts = [3, 0, 0, 0, 0, 0, 0, 0] * 2
        expect(all_counts_for_start_date).to match_array(expected_counts)
      end

      it 'has expected count at expected row (intake_final_fee) and column (date)' do
        intake_final_fee_counts = rows.find { |row| row['Name'].eql?('Intake final fee') }
        intake_final_fee_count_for_start_date = intake_final_fee_counts[start_date.strftime("%d/%m/%Y\n%A")].to_i

        expect(intake_final_fee_count_for_start_date).to eq(3)
      end
    end

    context 'with logging' do
      before { allow(LogStuff).to receive(:info) }

      let(:kwargs) { { query_set:, start_at: Date.current } }
      let(:query_set) { Stats::ManagementInformation::AGFSQuerySet.new }

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

<<<<<<< HEAD
      let(:kwargs) { { query_set:, start_at: Date.current } }
      let(:query_set) { Stats::ManagementInformation::AgfsQuerySet.new }
=======
      let(:kwargs) { { query_set: query_set, start_at: Date.current } }
      let(:query_set) { Stats::ManagementInformation::AGFSQuerySet.new }
>>>>>>> 5f2aebf8c (CFP-179 Zeitwerk: Inflect AGFS and update code)

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
