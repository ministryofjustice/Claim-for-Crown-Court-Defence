# frozen_string_literal: true

# Management information statistics
#
# Counts of records from the management information (V2)
# report filtered by various values, including a date. That
# date is specified as a range here.
#

Dir.glob(File.join(__dir__, 'concerns', '**', '*.rb')).each { |f| require_dependency f }
Dir.glob(File.join(__dir__, 'queries', '**', '*.rb')).each { |f| require_dependency f }

module Stats
  module ManagementInformation
    class DailyReportCountQuery
      def self.call(**kwargs)
        new(kwargs).call
      end

      def initialize(**kwargs)
        @scheme = kwargs[:scheme]&.to_s&.upcase
        @date_range = kwargs[:date_range]
        raise ArgumentError, 'scheme must be "agfs" or "lgfs"' if %w[AGFS LGFS].exclude?(@scheme)
        raise ArgumentError, 'date range must be provided' if @date_range.blank?
        set_queries
      end

      def call
        submission_queries + completion_queries
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
      # rubocop:disable Metrics/MethodLength
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
      # rubocop:enable Metrics/MethodLength

      def submission_queries
        @queries.each_with_object([]) do |(name, query), results|
          result = { name: name.to_s.humanize, filter: 'submissions' }
          @date_range.each do |day|
            result[day.iso8601] = query.call(scheme: @scheme,
                                             day: day.iso8601,
                                             date_column_filter: :originally_submitted_at).first['count']
          end
          results.append(result)
        end
      end

      def completion_queries
        @queries.each_with_object([]) do |(name, query), results|
          result = { name: name.to_s.humanize, filter: 'completions' }
          @date_range.each do |day|
            result[day.iso8601] = query.call(scheme: @scheme,
                                             day: day.iso8601,
                                             date_column_filter: :completed_at).first['count']
          end
          results.append(result)
        end
      end
    end
  end
end
