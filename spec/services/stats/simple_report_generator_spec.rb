require 'rails_helper'

RSpec.shared_examples 'a stats report CSV exporter' do
  let(:mocked_data) { [{ key1: 1, key2: 2 }] }
  let(:csv_exporter_output) { 'CSV exporter output' }
  let(:headers) { reporter::COLUMNS }

  before do
    allow(reporter).to receive(:call).and_return(mocked_data)
    allow(Stats::CsvExporter).to receive(:call).with(mocked_data, headers:).and_return(csv_exporter_output)
  end

  it 'uses the correct reporter' do
    call
    expect(reporter).to have_received(:call)
  end

  it { is_expected.to be_a(Stats::Result) }
  it { expect(call.content).to eq(csv_exporter_output) }
  it { expect(call.format).to eq('csv') }
end

RSpec.describe Stats::SimpleReportGenerator, type: :service do
  describe '.call' do
    subject(:call) { described_class.call(**options) }

    let(:options) { { report_type: } }

    context 'with a provisional assessment report' do
      let(:report_type) { 'provisional_assessment' }
      let(:reporter) { Reports::ProvisionalAssessments }

      it_behaves_like 'a stats report CSV exporter'
    end

    context 'with a rejections refusals report' do
      let(:report_type) { 'rejections_refusals' }
      let(:reporter) { Reports::RejectionsRefusals }

      it_behaves_like 'a stats report CSV exporter'
    end

    context 'with a submitted claims report' do
      let(:report_type) { 'submitted_claims' }
      let(:reporter) { Reports::SubmittedClaims }

      it_behaves_like 'a stats report CSV exporter'
    end
  end
end
