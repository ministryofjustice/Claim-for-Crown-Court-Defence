require 'rails_helper'

module Stats

  describe ManagementInformationGenerator, slack_bot: true do

    let(:generator)  { ManagementInformationGenerator.new }

    context 'data generation' do
      before(:all) do
        create :allocated_claim
        create :authorised_claim
        create :part_authorised_claim
        create :draft_claim
        Timecop.freeze(Time.new(2015, 3, 10, 11, 44, 55)) { create :allocated_claim }
      end

      after(:all) do
        clean_database
      end

      it 'creates a new management information record with a header and 3 lines in the report' do
        Timecop.freeze(Time.new(2016, 3, 10, 11, 44, 55)) do
          generator.run
          expect(StatsReport.count).to eq 1
          report = StatsReport.first
          expect(report.started_at).to eq Time.new(2016, 3, 10, 11, 44, 55)
          expect(report.status).to eq 'completed'
          expect(report.report.split("\n").size).to eq 4
        end
      end

      it 'creates an errored report if exception occurs' do
        expect(Settings).to receive(:claim_csv_headers).and_raise ArgumentError.new('XXXXXXXX')
        expect { generator.run }.to raise_exception(ArgumentError)

        expect(StatsReport.count).to eq 1
        report = StatsReport.first
        expect(report.status).to eq 'error'
        expect(report.report).to match /^ArgumentError - XXXXXX/
      end

    end
  end

end
