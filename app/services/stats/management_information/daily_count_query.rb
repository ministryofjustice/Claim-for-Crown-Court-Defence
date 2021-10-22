# frozen_string_literal: true

# Weekly management information statistics
#
# Daily counts of records from the management information (V2)
# report filtered by various values (see below. These are run
# daily and then entered into a weekly statistics report compiled
# by case workers by hand.
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

Dir.glob(File.join(__dir__, 'concerns', '**', '*.rb')).each { |f| require_dependency f }
Dir.glob(File.join(__dir__, 'queries', '**', '*.rb')).each { |f| require_dependency f }

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
        case @scheme
        when 'AGFS'
          agfs_queries
        when 'LGFS'
          lgfs_queries
        end
      end

      def agfs_queries
        agfs_stats.each_with_object([]) do |(name, query), results|
          result = { name: name.to_s.humanize }
          week_range.each do |day|
            result[day.strftime('%A').downcase.to_sym] = query.call(scheme: @scheme, day: day.iso8601).first['count']
          end
          results.append(result)
        end
      end

      # OPTIMIZE: inject this so we can avoid the agfs/lgfs conditional logic
      def agfs_stats
        {
          intake_fixed_fee: Agfs::IntakeFixedFeeQuery,
          intake_final_fee: Agfs::IntakeFinalFeeQuery,
          af1_high_value: Agfs::Af1HighValueQuery,
          af1_disk: Agfs::Af1DiskQuery,
          af2_redetermination: Agfs::Af2RedeterminationQuery,
          af2_high_value: Agfs::Af2HighValueQuery,
          af2_disk: Agfs::Af2DiskQuery,
          written_reasons: Agfs::WrittenReasonsQuery
        }
      end

      def lgfs_stats
        { test: nil }
      end

      def week_range
        @day.beginning_of_week(:saturday)..@day.end_of_week(:saturday)
      end
    end
  end
end
