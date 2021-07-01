require 'rails_helper'

RSpec.shared_examples 'csv exporter output' do
  it { is_expected.to eq expected_output_with_header }

  context 'when no headers are provided' do
    let(:options) { {} }

    it { is_expected.to eq expected_output_without_header }
  end
end

RSpec.describe Stats::CsvExporter do
  describe '.call' do
    subject(:service) { described_class.new(data, options).call }

    let(:options) { { headers: %w[column_1 column_2 column_3] } }
    let(:expected_output_with_header) do
      <<~CSVOUTPUT
        column_1,column_2,column_3
        row_1_column_1,row_1_column_2,row_1_column_3
        row_2_column_1,row_2_column_2,row_2_column_3
        row_3_column_1,row_3_column_2,row_3_column_3
        row_4_column_1,row_4_column_2,row_4_column_3
      CSVOUTPUT
    end
    let(:expected_output_without_header) do
      <<~CSVOUTPUT
        row_1_column_1,row_1_column_2,row_1_column_3
        row_2_column_1,row_2_column_2,row_2_column_3
        row_3_column_1,row_3_column_2,row_3_column_3
        row_4_column_1,row_4_column_2,row_4_column_3
      CSVOUTPUT
    end

    context 'when the data comprises hashes' do
      let(:data) {
        [
          { column_1: 'row_1_column_1', column_2: 'row_1_column_2', column_3: 'row_1_column_3' },
          { column_1: 'row_2_column_1', column_2: 'row_2_column_2', column_3: 'row_2_column_3' },
          { column_1: 'row_3_column_1', column_2: 'row_3_column_2', column_3: 'row_3_column_3' },
          { column_1: 'row_4_column_1', column_2: 'row_4_column_2', column_3: 'row_4_column_3' }
        ]
      }

      include_examples 'csv exporter output'
    end

    context 'when the data comprises arrays' do
      let(:data) {
        [
          %w[row_1_column_1 row_1_column_2 row_1_column_3],
          %w[row_2_column_1 row_2_column_2 row_2_column_3],
          %w[row_3_column_1 row_3_column_2 row_3_column_3],
          %w[row_4_column_1 row_4_column_2 row_4_column_3]
        ]
      }

      include_examples 'csv exporter output'
    end
  end
end
