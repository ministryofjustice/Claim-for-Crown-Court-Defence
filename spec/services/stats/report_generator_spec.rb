require 'rails_helper'

RSpec.describe Stats::ReportGenerator, type: :service do
  describe '.call' do
    subject(:result) { described_class.call(report, **options) }

    let(:options) { {} }

    context 'with a provisional assessment report' do
      let(:report) { 'provisional_assessment' }

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
        result
        expect(Reports::ProvisionalAssessments).to have_received(:call)
      end

      context 'with mocked data' do
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

    context 'with a rejectsions refusals report' do
      let(:report) { 'rejections_refusals' }
      let(:mocked_data) do
        [
          {
            provider_name: 'Provider Foo', provider_type: 'firm', supplier_number: '2A333Z',
            claims_issued: 23, rejections: 2, rejections_percent: 0.08, refusals: 17,
            refusals_percent: 0.74, rejections_refusals_percent: 0.87
          },
          {
            provider_name: 'Provider Foo', provider_type: 'firm', supplier_number: '2A444B',
            claims_issued: 45, rejections: 10, rejections_percent: 0.045, refusals: 22,
            refusals_percent: 0.49, rejections_refusals_percent: 0.71
          },
          {
            provider_name: 'Provider Foo', provider_type: 'chamber', supplier_number: '2A555G',
            claims_issued: 102, rejections: 24, rejections_percent: 0.24, refusals: 40,
            refusals_percent: 0.39, rejections_refusals_percent: 0.63
          },
          {
            provider_name: 'Provider Bar', provider_type: 'firm', supplier_number: '2A999Z',
            claims_issued: 76, rejections: 7, rejections_percent: 0.09, refusals: 31,
            refusals_percent: 0.41, rejections_refusals_percent: 0.5
          }
        ]
      end

      context 'with mocked data' do
        let(:expected_output) do
          <<~OUTPUT
            provider_name,provider_type,supplier_number,claims_issued,rejections,rejections_percent,refusals,refusals_percent,rejections_refusals_percent
            Provider Foo,firm,2A333Z,23,2,0.08,17,0.74,0.87
            Provider Foo,firm,2A444B,45,10,0.045,22,0.49,0.71
            Provider Foo,chamber,2A555G,102,24,0.24,40,0.39,0.63
            Provider Bar,firm,2A999Z,76,7,0.09,31,0.41,0.5
          OUTPUT
        end

        before do
          allow(Reports::RejectionsRefusals).to receive(:call).and_return(mocked_data)
          allow(Stats::CsvExporter)
            .to receive(:call)
            .with(mocked_data, headers: Reports::RejectionsRefusals::COLUMNS)
            .and_call_original
        end

        it { is_expected.to be_kind_of(Stats::Result) }
        it { expect(result.content).to eq(expected_output) }
        it { expect(result.format).to eq('csv') }
      end
    end

    context 'with a submitted claims report' do
      let(:report) { 'submitted_claims' }
      let(:rows) { CSV.parse(result.content) }

      before do
        travel_to(Date.parse('1 July 2021'))
        create(:claim, original_submission_date: Time.zone.parse('28 June 2021 01:01'))
        create(:claim, original_submission_date: Time.zone.parse('27 June 2021 15:31'))
        create(:claim, original_submission_date: Time.zone.parse('21 June 2021 01:01'))
        create(:claim, original_submission_date: Time.zone.parse('19 June 2021 12:00'))
        create(:claim, original_submission_date: Time.zone.parse('16 June 2021 12:00'))
        create(:claim, original_submission_date: Time.zone.parse('9 June 2021 12:00'))
        create(:claim, original_submission_date: Time.zone.parse('2 June 2021 12:00'))
        create(:claim, original_submission_date: Time.zone.parse('26 May 2021 12:00'))
        create(:claim, original_submission_date: Time.zone.parse('19 May 2021 12:00'))
        create(:claim, original_submission_date: Time.zone.parse('12 May 2021 12:00'))
        create(:claim, original_submission_date: Time.zone.parse('5 May 2021 12:00'))
        create(:claim, original_submission_date: Time.zone.parse('28 April 2021 12:00'))
        create(:claim, original_submission_date: Time.zone.parse('21 April 2021 12:00'))
        create(:claim, original_submission_date: Time.zone.parse('14 April 2021 12:00'))
        create(:claim, original_submission_date: Time.zone.parse('7 April 2021 12:00'))
        create(:claim, original_submission_date: Time.zone.parse('4 April 2021 12:00'))
        create_list(:claim, 5, original_submission_date: nil)
      end

      after { travel_back }

      it 'sets the correct headings' do
        expect(rows.first).to match_array(['Week starting', 'Submitted claims'])
      end

      it 'counts the number of submitted claims for last week' do
        expect(rows.last).to match_array(['21/06/2021', '2'])
      end

      it 'has results for the past 12 weeks' do
        t = Time.zone.parse('21 June 2021')
        last_twelve_mondays = Array.new(12) { |i| (t - i.weeks).strftime('%d/%m/%Y') }
        expect(rows.map(&:first)).to match_array(['Week starting', *last_twelve_mondays])
      end
    end
  end
end
