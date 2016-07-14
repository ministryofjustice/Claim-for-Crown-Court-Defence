require 'rails_helper'

module Stats
  module Collector
    describe ClaimRedeterminationsCollector do

      let(:report_day) { Date.today }

      before(:each) do
        create_claim(:redetermination,  report_day)
        create_claim(:redetermination,  report_day - 1.days)
        create_claim(:redetermination,  report_day - 1.days)
        create_claim(:draft,            report_day - 2.days) # will be ignored (not a redetermination)
        create_claim(:redetermination,  report_day - 5.days)
        create_claim(:redetermination,  report_day - 8.days) # will be ignored (out of 7-days range)
      end

      after(:all) { clean_database }

      describe '#collect' do
        it 'calculates the redeterminations 7 days moving average' do
          expect(Statistic.count).to eq 0

          ClaimRedeterminationsCollector.new(report_day).collect

          stats = Statistic.find_by_date_and_report_name(report_day, 'redeterminations_average').to_a
          expect(stats.size).to eq(1)
          expect(stats.first.value_1).to eq(1) # 7-days average (rounded to closest integer)
          expect(stats.first.value_2).to eq(4) # 7-days total
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