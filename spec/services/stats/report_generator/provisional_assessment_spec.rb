require 'rails_helper'

RSpec.describe Stats::ReportGenerator::ProvisionalAssessment, type: :service do
  describe '.call' do
    let(:mocked_data) { 'mocked_data' }
    let(:mocked_csv_output) do
      <<~CSV
        header1,header2,header3
        row11,row12,row13
        row21,row22,row23
      CSV
    end

    before do
      allow(Stats::CsvExporter).to receive(:call).and_return(mocked_csv_output)
    end

    it 'retrieves the data for the report' do
      allow(Reports::ProvisionalAssessments).to receive(:call)
      described_class.call
      expect(Reports::ProvisionalAssessments).to have_received(:call)
    end

    context 'with mocked data' do
      subject(:result) { described_class.call }

      before do
        allow(Reports::ProvisionalAssessments).to receive(:call).and_return(mocked_data)
        allow(Stats::CsvExporter)
          .to receive(:call)
          .with(mocked_data, headers: Reports::ProvisionalAssessments::COLUMNS)
          .and_return(mocked_csv_output)
      end

      it { is_expected.to be_kind_of(Stats::Result) }
      it { expect(result.content).to eq(mocked_csv_output) }
      it { expect(result.format).to eq('csv') }
    end
  end
end
