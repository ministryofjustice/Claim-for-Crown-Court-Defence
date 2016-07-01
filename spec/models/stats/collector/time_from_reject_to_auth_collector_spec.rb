require 'rails_helper'

module Stats
  module Collector
    describe TimeFromRejectToAuthCollector do

      include DatabaseHousekeeping

      before(:all) do
        @period_end = Date.today.end_of_day
        @period_start = (@period_end - 7.days).beginning_of_day
        @unloned_before = create_uncloned_claim_during_period
        @cloned_during_1 = create_cloned_claim_during_period(5.hours, 73.hours)
        @coned_during_2 = create_cloned_claim_during_period(2.days, 96.hours)
        @cb = create_cloned_claim_before_period
        @al = create_unauthorised_claim_during_period
      end

      after(:all) do
        clean_database
      end

      it 'should get all claims within the last 7 days that were authorised with a clone source' do
        date = @period_end.to_date
        TimeFromRejectToAuthCollector.new(date).collect
        recs = Statistic.where(date: date, report_name: 'time_reject_to_auth')
        expect(recs.size).to eq 1
        expect(recs.first.value_2).to eq 2
        expect(recs.first.value_1).to eq ((73.hours + 96.hours) / 2)
      end

      def create_uncloned_claim_during_period
        claim = create :authorised_claim
        claim.authorised_at = @period_start + 2.days
      end

      def create_cloned_claim_during_period(time_before_period_end_authorised, time_before_authorisation_rejected)
        claim = create :authorised_claim
        claim.authorised_at = @period_end - time_before_period_end_authorised
        create_source_claim(claim, time_before_authorisation_rejected)
        claim
      end

      def create_cloned_claim_before_period
        claim = create :authorised_claim
        claim.authorised_at = @period_start - 2.days
        create_source_claim(claim, 10.days)
        claim
      end

      def create_unauthorised_claim_during_period
        create :allocated_claim
      end

      def create_source_claim(cloned_claim, time_before_authorisation_rejected)
        source_claim = create :rejected_claim
        cloned_claim.clone_source_id = source_claim.id
        cloned_claim.save!
        reject_transition = source_claim.claim_state_transitions.detect{ |cst| cst.to == 'rejected' }
        reject_transition.created_at = cloned_claim.authorised_at - time_before_authorisation_rejected
        reject_transition.save!
      end

    end
  end
end
