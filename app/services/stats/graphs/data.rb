module Stats
  module Graphs
    class Data

      def initialize(**kwargs)


        (@from, @to) = validate_dates(kwargs[:from], kwargs[:to])
      end

      def call
        Claim::BaseClaim.active.non_draft
                        .where(last_submitted_at: @from..@to).find_each
                        .group_by(&:fee_scheme)
                        .sort_by { |fee_scheme, _claims| [fee_scheme.name, fee_scheme.version] }
                        .to_h
                        .transform_keys { |fee_scheme| "#{fee_scheme.name} #{fee_scheme.version}" }
                        .transform_values(&:count)

      end

      private

      def validate_dates(from, to)
        return [Time.current.at_beginning_of_month, nil] if from.nil? || to.nil?
        return [Time.current.at_beginning_of_month, nil] if to.before?(from)
        [from, to]
      end
    end
  end
end
