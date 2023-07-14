require 'rails_helper'

module Stats
  module Collector
    describe ClaimCreationSourceCollector do
      before(:all) do
        travel_to report_day do
          create(:draft_claim, source: 'web')
          create(:submitted_claim, source: 'api_web_edited')
          create(:draft_claim, source: 'api')
        end
      end

      after(:all) { clean_database }

      describe '#collect' do
        before(:all) do
          ClaimCreationSourceCollector.new(report_day).collect
        end

        it 'counts the created claims on that day for source web' do
          stats = Statistic.find_by_date_and_report_name(report_day, 'creations_source_web').to_a
          expect(stats.size).to eq 1

          stat = stats.first
          expect(stat.claim_type).to eq 'Claim::BaseClaim'
          expect(stat.value_1).to eq 1
        end

        it 'counts the created claims on that day for source api' do
          stats = Statistic.find_by_date_and_report_name(report_day, 'creations_source_api').to_a
          expect(stats.size).to eq 1

          stat = stats.first
          expect(stat.claim_type).to eq 'Claim::BaseClaim'
          expect(stat.value_1).to eq 2
        end
      end

      def report_day
        Time.zone.local(2018, 3, 5, 11, 44, 55)
      end
    end
  end
end
