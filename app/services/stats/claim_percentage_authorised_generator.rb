module Stats
  class ClaimPercentageAuthorisedGenerator
    def initialize
      @decided_claims_by_state = {}
    end

    def run
      percentages = calculate_percentages
      geckoize_percentages(percentages)
    end

    private

    def calculate_percentages
      calculate_claims_decided_this_month
      total_claims = @decided_claims_by_state.values.sum
      percentages = {}
      @decided_claims_by_state.keys.sort_by { |k, _v| k.to_s }.reverse.each do |state|
        percentages[state] = @decided_claims_by_state[state].to_f / total_claims.to_f * 100
      end
      percentages
    end

    def geckoize_percentages(percentages)
      result_array = []
      percentages.each do |state, value|
        result_array << { value: value, text: state.to_s.humanize }
      end
      { item: result_array }
    end

    def calculate_claims_decided_this_month
      %i[authorised part_authorised rejected refused].each do |state|
        @decided_claims_by_state[state] = claims_decided_this_month(state)
      end
      combine_rejected_and_refused
    end

    def combine_rejected_and_refused
      rejected_refused = @decided_claims_by_state.delete(:rejected) + @decided_claims_by_state.delete(:refused)
      @decided_claims_by_state['rejected/refused'] = rejected_refused
    end

    def claims_decided_this_month(state)
      ClaimStateTransition.decided_this_month(state)
    end
  end
end
