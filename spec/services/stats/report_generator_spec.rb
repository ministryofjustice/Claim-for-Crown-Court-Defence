require 'rails_helper'

RSpec.shared_examples 'package stats in CSV' do
  let(:mocked_data) { [{ key1: 1, key2: 2 }] }
  let(:csv_exporter_output) { 'CSV exporter output' }
  let(:headers) { reporter::COLUMNS }

  before do
    allow(reporter).to receive(:call).and_return(mocked_data)
    allow(Stats::CsvExporter).to receive(:call).with(mocked_data, headers: headers).and_return(csv_exporter_output)
  end

  it 'uses the the correct reporter' do
    result
    expect(reporter).to have_received(:call)
  end

  it { is_expected.to be_kind_of(Stats::Result) }
  it { expect(result.content).to eq(csv_exporter_output) }
  it { expect(result.format).to eq('csv') }
end

RSpec.describe Stats::ReportGenerator, type: :service do
  describe '.call' do
    subject(:result) { described_class.call(report, **options) }

    let(:options) { {} }

    context 'with a provisional assessment report' do
      let(:report) { 'provisional_assessment' }
      let(:reporter) { Reports::ProvisionalAssessments }

      include_examples 'package stats in CSV'
    end

    context 'with a rejections refusals report' do
      let(:report) { 'rejections_refusals' }
      let(:reporter) { Reports::RejectionsRefusals }

      include_examples 'package stats in CSV'
    end

    context 'with a submitted claims report' do
      let(:report) { 'submitted_claims' }
      let(:reporter) { Reports::SubmittedClaims }

      include_examples 'package stats in CSV'
    end
  end
end
