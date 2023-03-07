# frozen_string_literal: true

RSpec.describe Stats::ManagementInformation::DailyReportCountQuery do
  describe '.call' do
    subject(:call) { described_class.call(**kwargs) }

    let(:kwargs) { { date_range: 1.month.ago.to_date..Time.zone.today, scheme: 'lgfs' } }

    let(:instance) { instance_double(described_class) }
    let(:result) { instance_double(Stats::Result) }

    before do
      allow(described_class).to receive(:new).with(any_args).and_return(instance)
      allow(instance).to receive(:call).and_return(result)
    end

    it 'sends \'new\' with arguments' do
      call
      expect(described_class).to have_received(:new).with(hash_including(:scheme, :date_range))
    end

    it 'sends \'call\' to instance of class' do
      call
      expect(instance).to have_received(:call)
    end
  end

  describe '#call' do
    subject(:call) { described_class.new(**kwargs).call }

    let(:month_range) { 1.month.ago.to_date..Time.zone.today }

    context 'without query_set' do
      let(:kwargs) { { date_range: month_range } }

      it { expect { call }.to raise_error ArgumentError, 'query set must be provided' }
    end

    context 'without date range' do
      let(:kwargs) { { query_set: { foo: :bar } } }

      it { expect { call }.to raise_error ArgumentError, 'date range must be provided' }
    end

    context 'with query_set and date range' do
      subject(:result) { described_class.new(**kwargs).call }

      let(:kwargs) { { query_set: Stats::ManagementInformation::AgfsQuerySet.new, date_range: month_range } }

      let(:expected_result_keys) do
        month_range.to_a.collect(&:iso8601).prepend(:name, :filter)
      end

      let(:expected_result_values_types) do
        ([instance_of(Integer)] * month_range.to_a.size).prepend(instance_of(String), instance_of(String))
      end

      it { is_expected.to be_a(Array) }

      it 'each element of array returns hash with expected keys' do
        expect(result.map(&:keys)).to all(match_array(expected_result_keys))
      end

      it 'each element of array returns hash with expected value types' do
        expect(result.map(&:values)).to all(match_array(expected_result_values_types))
      end

      context 'with AGFS query_set' do
        let(:kwargs) { { query_set: Stats::ManagementInformation::AgfsQuerySet.new, date_range: month_range } }

        let(:expected_result_names) do
          ['Intake fixed fee', 'Intake final fee',
           'AF1 high value', 'AF1 disk',
           'AF2 redetermination', 'AF2 high value', 'AF2 disk',
           'Written reasons'] * 2
        end

        it 'each element of array has expected :name value' do
          expect(result.pluck(:name)).to match_array(expected_result_names)
        end
      end

      context 'with LGFS query_set' do
        let(:kwargs) { { query_set: Stats::ManagementInformation::LgfsQuerySet.new, date_range: month_range } }

        let(:expected_result_names) do
          ['Intake fixed fee', 'Intake final fee',
           'LF1 high value', 'LF1 disk',
           'LF2 redetermination', 'LF2 high value', 'LF2 disk',
           'Written reasons', 'Intake interim fee'] * 2
        end

        it 'each element of array has expected :name value' do
          expect(result.pluck(:name)).to match_array(expected_result_names)
        end
      end
    end
  end
end
