module Stats
  module Graphs
    class SixMonthPeriod
      def initialize
        @from = 5.months.ago.at_beginning_of_month
        @to = Time.current
      end

      def call
        generate_six_month_breakdown(@from, @to)
      end

      def title
        "#{@from.strftime('%B')} - #{@to.strftime('%B')}"
      end

      private

      def ordered_fee_schemes
        @ordered_fee_schemes ||= FeeScheme.where(name: %w[AGFS LGFS]).order(:name, :version)
                                          .map { |scheme| "#{scheme.name} #{scheme.version}" }
      end

      def last_six_months
        output = []
        6.times do |offset|
          month = (@to - offset.month).strftime('%b')
          output << month
        end
        output.reverse
      end

      def empty_linechart_array
        output = []
        ordered_fee_schemes.each do |scheme|
          output.append({ name: scheme, data: Hash.new(0) })
          last_six_months.each do |month|
            output[-1][:data][month] = 0
          end
        end
        output
      end

      def generate_six_month_breakdown(from, to)
        output = empty_linechart_array

        Claim::BaseClaim.active.non_draft.where(last_submitted_at:
                                                  from..to).find_each do |claim|
          output.each do |hash|
            if hash[:name] == "#{claim.fee_scheme.name} #{claim.fee_scheme.version}"
              hash[:data][claim.last_submitted_at.strftime('%b')] += 1
            end
          end
        end
        output
      end
    end
  end
end
