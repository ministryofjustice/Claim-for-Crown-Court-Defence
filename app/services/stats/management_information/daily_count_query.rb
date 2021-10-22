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

        set_queries
      end

      def call
        queries
      end

      private

      # OPTIMIZE: invert this so we can avoid the agfs/lgfs conditional logic
      def set_queries
        case @scheme
        when 'AGFS'
          @queries = agfs_queries
        when 'LGFS'
          @queries = lgfs_queries
        end
      end

      # OPTIMIZE: invert this so we can avoid the agfs/lgfs conditional logic
      def agfs_queries
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

      # OPTIMIZE: invert this so we can avoid the agfs/lgfs conditional logic
      def lgfs_queries
        {
          intake_fixed_fee: Lgfs::IntakeFixedFeeQuery,
          intake_final_fee: Lgfs::IntakeFinalFeeQuery,
          lf1_high_value: Lgfs::Lf1HighValueQuery,
          lf1_disk: Lgfs::Lf1DiskQuery,
          lf2_redetermination: Lgfs::Lf2RedeterminationQuery,
          lf2_high_value: Lgfs::Lf2HighValueQuery,
          lf2_disk: Lgfs::Lf2DiskQuery,
          written_reasons: Lgfs::WrittenReasonsQuery,
          intake_interim_fee: Lgfs::IntakeInterimFeeQuery
        }
      end

      def queries
        @queries.each_with_object([]) do |(name, query), results|
          result = { name: name.to_s.humanize }
          week_range.each do |day|
            result[day.strftime('%A').downcase.to_sym] = query.call(scheme: @scheme, day: day.iso8601).first['count']
          end
          results.append(result)
        end
      end

      def week_range
        @day.beginning_of_week(:saturday)..@day.end_of_week(:saturday)
      end
    end
  end
end
