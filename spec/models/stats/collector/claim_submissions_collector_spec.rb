require 'rails_helper'

module Stats
  module Collector
    describe ClaimSubmissionsCollector do

      let(:report_day) { 5.days.ago }

      before(:each) do
        create_claim(:submitted, report_day - 2.days)
        create_claim(:draft, report_day)
        create_claim(:submitted, report_day)
        create_claim(:submitted, report_day)
        create_claim(:submitted, report_day + 2.days)
      end

      after(:all) { clean_database }

      describe '#collect' do
        it 'counts the submitted claims on that day for each claim type' do
          expect(Statistic.count).to eq 0
          ClaimSubmissionsCollector.new(report_day).collect
          stats = Statistic.find_by_date_and_report_name(report_day, 'claim_submissions').to_a
          expect(stats.size).to eq 4

          stat = stats.shift
          expect(stat.claim_type).to eq 'Claim::AdvocateClaim'
          expect(stat.value_1).to eq 2

          stat = stats.shift
          expect(stat.claim_type).to eq 'Claim::InterimClaim'
          expect(stat.value_1).to eq 0

          stat = stats.shift
          expect(stat.claim_type).to eq 'Claim::LitigatorClaim'
          expect(stat.value_1).to eq 0

          stat = stats.shift
          expect(stat.claim_type).to eq 'Claim::TransferClaim'
          expect(stat.value_1).to eq 0
        end
      end


      def create_claim(state, date)
        Timecop.freeze(date) do
          create factory_name(state)
        end
      end

      def factory_name(state)
        "#{state}_claim".to_sym
      end
    end
  end
end