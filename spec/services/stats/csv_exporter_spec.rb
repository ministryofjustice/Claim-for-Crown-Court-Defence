require 'rails_helper'

RSpec.shared_examples 'csv exporter output' do
  describe '.call' do
    subject(:service) { described_class.new(data, options).call }

    let(:test_data) {
      [
        { column_1: 'row_1_column_1', column_2: 'row_1_column_2', column_3: 'row_1_column_3' },
        { column_1: 'row_2_column_1', column_2: 'row_2_column_2', column_3: 'row_2_column_3' },
        { column_1: 'row_3_column_1', column_2: 'row_3_column_2', column_3: 'row_3_column_3' },
        { column_1: 'row_4_column_1', column_2: 'row_4_column_2', column_3: 'row_4_column_3' }
      ]
    }

    context 'when headers are provided' do
      let(:options) { { headers: %w[column_1 column_2 column_3] } }
      let(:expected_output) do
        <<~CSVOUTPUT
          column_1,column_2,column_3
          row_1_column_1,row_1_column_2,row_1_column_3
          row_2_column_1,row_2_column_2,row_2_column_3
          row_3_column_1,row_3_column_2,row_3_column_3
          row_4_column_1,row_4_column_2,row_4_column_3
        CSVOUTPUT
      end

      it { is_expected.to eq expected_output }
    end

    context 'when no headers are provided' do
      let(:options) { {} }
      let(:expected_output) do
        <<~CSVOUTPUT
          row_1_column_1,row_1_column_2,row_1_column_3
          row_2_column_1,row_2_column_2,row_2_column_3
          row_3_column_1,row_3_column_2,row_3_column_3
          row_4_column_1,row_4_column_2,row_4_column_3
        CSVOUTPUT
      end

      it { is_expected.to eq expected_output }
    end
  end
end

RSpec.describe Stats::CsvExporter do
  context 'when the data comprises hashes' do
    let(:data) { test_data }

    include_examples 'csv exporter output'
  end

  context 'when the data comprises arrays' do
    let(:data) { test_data.map(&:values) }

    include_examples 'csv exporter output'
  end
end
