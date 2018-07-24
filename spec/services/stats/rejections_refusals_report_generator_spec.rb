require 'rails_helper'

RSpec.describe Stats::RejectionsRefusalsReportGenerator, type: :service do
  describe '.call' do
    let(:mocked_data) {
      [
        { provider_name: 'Provider Foo', provider_type: 'firm', supplier_number: '2A333Z', claims_issued: 23, rejections: 2, rejections_percent: 0.08, refusals: 17, refusals_percent: 0.74, rejections_refusals_percent: 0.87 },
        { provider_name: 'Provider Foo', provider_type: 'firm', supplier_number: '2A444B', claims_issued: 45, rejections: 10, rejections_percent: 0.045, refusals: 22, refusals_percent: 0.49, rejections_refusals_percent: 0.71 },
        { provider_name: 'Provider Foo', provider_type: 'chamber', supplier_number: '2A555G', claims_issued: 102, rejections: 24, rejections_percent: 0.24, refusals: 40, refusals_percent: 0.39, rejections_refusals_percent: 0.63 },
        { provider_name: 'Provider Bar', provider_type: 'firm', supplier_number: '2A999Z', claims_issued: 76, rejections: 7, rejections_percent: 0.09, refusals: 31, refusals_percent: 0.41, rejections_refusals_percent: 0.5 }
      ]
    }

    it 'exports the retrieved data' do
      expect(Reports::RejectionsRefusals).to receive(:call).and_return(mocked_data)
      expect(Stats::CsvExporter)
        .to receive(:call)
        .with(mocked_data, headers: Reports::RejectionsRefusals::COLUMNS)
        .and_call_original
      result = described_class.call
      expect(result).to be_kind_of(Stats::Result)
      expected_output = <<~OUTPUT
      provider_name,provider_type,supplier_number,claims_issued,rejections,rejections_percent,refusals,refusals_percent,rejections_refusals_percent
      Provider Foo,firm,2A333Z,23,2,0.08,17,0.74,0.87
      Provider Foo,firm,2A444B,45,10,0.045,22,0.49,0.71
      Provider Foo,chamber,2A555G,102,24,0.24,40,0.39,0.63
      Provider Bar,firm,2A999Z,76,7,0.09,31,0.41,0.5
      OUTPUT
      expect(result.content).to eq(expected_output)
      expect(result.format).to eq('csv')
    end
  end
end
