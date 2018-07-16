require 'rails_helper'

RSpec.describe Stats::ProvisionalAssessmentReportGenerator, type: :service do
  describe '.call' do
    let(:mocked_data) { double(:mocked_data) }
    let(:mocked_csv_output) {
      %[header1,header2,header3\n
      row11,row12,row13\n
      row21,row22,row23
      ]
    }

    before do
      allow(Stats::CsvExporter).to receive(:call).and_return(mocked_csv_output)
    end

    it 'retrieves the data for the report' do
      expect(Reports::ProvisionalAssessments).to receive(:call)
      described_class.call
    end

    it 'exports the retrieved data' do
      expect(Reports::ProvisionalAssessments).to receive(:call).and_return(mocked_data)
      expect(Stats::CsvExporter)
        .to receive(:call)
        .with(mocked_data, headers: Reports::ProvisionalAssessments::COLUMNS)
        .and_return(mocked_csv_output)
      expect(described_class.call).to eq(mocked_csv_output)
    end
  end
end
