module Stats
  module Collector
    class DraftToSubmittedTime

      SECONDS_IN_DAY = 60 * 60 * 24

      def initialize
        @num_claims = 0
        @total_days = 0
        @count_by_days = Hash.new(0)
      end

      def run
        claim_ids = Claim::BaseClaim.all.pluck(:id)
        claim_ids.each { |claim_id| calculate_time_draft_to_submitted(claim_id) }
        print_results
      end

      private

      def first_submitted_at(claim)
        transition_to_submitted = claim.claim_state_transitions.select{ |cst| cst.to == 'submitted' }
        first_transmisison_to_submitted = transition_to_submitted.sort{ |a, b| a.created_at <=> b.created_at }.first
        first_transmisison_to_submitted.created_at
      end

      def calculate_time_draft_to_submitted(claim_id)
        claim = Claim::BaseClaim.find claim_id
        if claim.state != 'draft'
          period_in_secs = first_submitted_at(claim) - claim.created_at
          period_in_days = (period_in_secs / SECONDS_IN_DAY).to_i
          update_totals(period_in_days)
        end
      end

      def update_totals(val)
        @count_by_days[val] += 1
        @num_claims += 1
        @total_days += val
      end

      def print_results
        puts "Number of claims analysed: #{@num_claims}"
        puts "Average days between create and submit: #{(@total_days / @num_claims.to_f).round(2)}"
        puts "Distribution:"
        @count_by_days.keys.sort.each do |key|
          puts "  #{key} days:  #{@count_by_days[key]} claims"
        end
      end
    end
  end
end