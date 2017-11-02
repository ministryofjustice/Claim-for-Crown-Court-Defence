require 'rails_helper'

module Stats
  module Collector
    describe ClaimCreationSourceCollector do

      before(:all) do
        create_claim(:draft, report_day, source: 'web')
        create_claim(:submitted, report_day, source: 'api_web_edited')
        create_claim(:draft, report_day, source: 'api')
        create_claim(:submitted, report_day, source: 'json_import')
        create_claim(:submitted, report_day, source: 'json_import_web_edited')
        create_claim(:draft, report_day, source: 'json_import')
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

        it 'counts the created claims on that day for source json' do
          stats = Statistic.find_by_date_and_report_name(report_day, 'creations_source_json').to_a
          expect(stats.size).to eq 1

          stat = stats.first
          expect(stat.claim_type).to eq 'Claim::BaseClaim'
          expect(stat.value_1).to eq 3
        end
      end

      def report_day
        Timecop.freeze(Time.new(2016, 3, 10, 11, 44, 55)) { 5.days.ago }
      end

      def create_claim(state, date, attributes = {})
        Timecop.freeze(date) do
          FactoryBot.create(factory_name(state), attributes)
        end
      end

      def factory_name(state)
        "#{state}_claim".to_sym
      end
    end
  end
end