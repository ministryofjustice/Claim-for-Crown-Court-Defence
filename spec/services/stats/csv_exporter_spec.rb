require 'rails_helper'

RSpec.describe Stats::CsvExporter do
  describe '.call' do
    let(:headers) { %w[column_1 column_2 column_3] }
    let(:options) { { headers: headers } }
    let(:data) {
      [
        { column_1: 'row_1_column_1', column_2: 'row_1_column_2', column_3: 'row_1_column_3' },
        { column_1: 'row_2_column_1', column_2: 'row_2_column_2', column_3: 'row_2_column_3' },
        { column_1: 'row_3_column_1', column_2: 'row_3_column_2', column_3: 'row_3_column_3' },
        { column_1: 'row_4_column_1', column_2: 'row_4_column_2', column_3: 'row_4_column_3' }
      ]
    }

    subject(:service) { described_class.new(data, options) }

    it 'returns a CSV string with the provided data including the headers' do
      expected_output = <<-CSVOUTPUT.strip_heredoc
      column_1,column_2,column_3
      row_1_column_1,row_1_column_2,row_1_column_3
      row_2_column_1,row_2_column_2,row_2_column_3
      row_3_column_1,row_3_column_2,row_3_column_3
      row_4_column_1,row_4_column_2,row_4_column_3
      CSVOUTPUT
      expect(service.call).to eq(expected_output)
    end

    context 'when no headers are provided' do
      let(:options) { {} }

      it 'returns a CSV string with only the provided data' do
        expected_output = <<-CSVOUTPUT.strip_heredoc
        row_1_column_1,row_1_column_2,row_1_column_3
        row_2_column_1,row_2_column_2,row_2_column_3
        row_3_column_1,row_3_column_2,row_3_column_3
        row_4_column_1,row_4_column_2,row_4_column_3
        CSVOUTPUT
        expect(service.call).to eq(expected_output)
      end
    end
  end
end
