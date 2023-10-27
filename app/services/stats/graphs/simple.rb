module Stats
  module Graphs
    class Simple
      def initialize(**kwargs)
        (@from, @to) = validate_dates(kwargs[:from], kwargs[:to])
      end

      def call(&)
        claims_by_fee_scheme.transform_values(&)
      end

      def title
        "#{@from.strftime('%d %b')} - #{@to.strftime('%d %b')}"
      end

      private

      def validate_dates(from, to)
        #ToDO: Figure out some way to return the error flag
        return [Time.current.at_beginning_of_month, Time.current] if from.nil? || to.nil?
        return [Time.current.at_beginning_of_month, Time.current] if to.before?(from)
        [from, to]
      end

      def claims_by_fee_scheme
        Claim::BaseClaim.active.non_draft
                        .where(last_submitted_at: @from..@to).find_each
                        .group_by(&:fee_scheme)
                        .sort_by { |fee_scheme, _claims| [fee_scheme.name, fee_scheme.version] }
                        .to_h
                        .transform_keys { |fee_scheme| "#{fee_scheme.name} #{fee_scheme.version}" }
      end
    end
  end
end
