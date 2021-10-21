# frozen_string_literal: true

# Weekly management information statistics
#
# Daily counts of records from the management information (V2)
# report filtered by various values (see below. These are run
# daily and then entered into a weekly statistics report compiled
# by case workers by hand.
#
# Note that claim archival makes running this
#
# Filters include one or more of those below
#
# This prefixed by query are available in the journey query itself
# those prefixed by presenter are only, currently available in the
# presented object
# - scheme
# - case_type_name
# - submission_type
# - original_submission_date
# - disk_evidence
# - claim_total
#

Dir[File.join(__dir__, 'concerns', '*.rb')].each { |f| require_dependency f }
Dir[File.join(__dir__, 'queries', '*.rb')].each { |f| require_dependency f }

module Stats
  module ManagementInformation
    class DailyCountQuery
      def self.call(options = {})
        new(options).call
      end

      def initialize(options = {})
        @scheme = options[:scheme]&.to_s&.upcase
        @day = options[:day]
        raise ArgumentError, 'scheme must be "agfs" or "lgfs"' if @scheme.present? && %w[AGFS LGFS].exclude?(@scheme)
        raise ArgumentError, 'day must be provided' if @day.blank?
      end

      def call
        queries
      end

      private

      def queries
        stats.each_with_object([]) do |(name, query), results|
          result = { name: name.to_s.humanize }
          week_range.each do |day|
            result[day.strftime('%A').downcase.to_sym] = query.call(scheme: @scheme, day: day.iso8601).first['count']
          end
          results.append(result)
        end
      end

      def stats
        {
          intake_fixed_fee: IntakeFixedFeeQuery,
          intake_final_fee: IntakeFinalFeeQuery,
          af1_high_value: Af1HighValueQuery,
          af1_disk: Af1DiskQuery,
          af2_redetermination: Af2RedeterminationQuery,
          af2_high_value: Af2HighValueQuery,
          af2_disk: Af2DiskQuery,
          written_reasons: WrittenReasonsQuery
        }
      end

      def week_range
        @day.beginning_of_week(:saturday)..@day.end_of_week(:saturday)
      end
    end
  end
end
