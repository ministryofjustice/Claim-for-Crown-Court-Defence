require 'rails_helper'
require File.join(Rails.root, 'lib', 'demo_data', 'claim_state_advancer')

module Stats
  module Collector
    describe TimeToCompletionCollector do

      let(:base_time) { Time.new(2016, 1, 1, 12, 0, 0) }
      let(:decision_time) { base_time + 14.days }

      let(:decision_methods) do
        {
          'authorised' => :authorise,
          'part_authorise' => :part_authorise,
          'rejected' => :reject,
          'refused' => :refuse
        }
      end

      let(:case_worker_user) { create :user, email: 'caseworker@example.com' }
      let(:case_worker) { create :case_worker }
      let(:advocate_user) { create :user, email: 'advocate@example.com' }
      let(:advocate) { create :external_user, user: advocate_user }

      before(:each) do
        case_worker.user = case_worker_user
        @claim_a = create :draft_claim, external_user: advocate, creator: advocate
        @claim_b = create_submitted_claim(base_time + 3.days)
        @claim_c = create_decided_claim('authorised', base_time + 10.days, decision_time)
        @claim_d = create_decided_claim('rejected', base_time + 13.days, decision_time)
        @claim_e = create_decided_claim('refused', base_time + 2.days, decision_time)
        @claim_f = create_decided_claim('authorised', base_time + 10.days, decision_time + 2.days)
      end


      it 'should work out the average time to completion' do
        # the following claims should be authorised on decision day:
        # - claim_c - submitted 4 days earlier
        # - claim_d - submitted 1 day earlier
        # - claim_2 - submitted 12 days earlier
        # so the average time to submission should be 17/3 = 5.66 days, with a count of 3
        decision_day = decision_time.to_date
        TimeToCompletionCollector.new(decision_day).collect
        stats = Statistic.report('completion_time', 'Claim::BaseClaim', decision_day, decision_day)
        expect(stats.size).to eq 1
        stat = stats.first
        expect(stat.value_1).to eq 566
        expect(stat.value_2).to eq 3
      end


      def create_submitted_claim(time_submitted)
        claim = nil
        Timecop.freeze(base_time) do
          claim = create :draft_claim, external_user: advocate, creator: advocate
          Timecop.freeze(time_submitted) do
            claim.submit!
          end
        end
        claim
      end

      def create_decided_claim(final_state, time_submitted, decision_time)
        claim = create_submitted_claim(time_submitted)
        Timecop.freeze(decision_time) do
          claim.allocate!
          DemoData::ClaimStateAdvancer.new(claim).advance_from_allocated_to(final_state)
        end
      end

      def authorise

      end




    end
  end
end