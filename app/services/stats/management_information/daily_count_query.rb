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

Dir[Rails.root.join('app', 'services', 'stats', 'management_information', 'concerns', '*.rb')].each { |f| require_dependency f }
Dir[Rails.root.join('app', 'services', 'stats', 'management_information', 'queries', '*.rb')].each { |f| require_dependency f }

module Stats
  module ManagementInformation
    class DailyCountQuery
      def self.call(options = {})
        new(options).call
      end

      def initialize(options = {})
        @scheme = options[:scheme]&.to_s&.upcase
        @day = options[:day]&.iso8601
        raise ArgumentError, 'scheme must be "agfs" or "lgfs"' if @scheme.present? && %w[AGFS LGFS].exclude?(@scheme)
      end

      def call
        queries
      end

      private

      def queries
        {
          intake_fixed_fee: IntakeFixedFeeQuery.call(**args).first['count'],
          intake_final_fee: IntakeFinalFeeQuery.call(**args).first['count'],
          af1_high_value: Af1HighValueQuery.call(**args).first['count'],
          af1_disk: Af1DiskQuery.call(**args).first['count'],
          af2_redetermination: Af2RedeterminationQuery.call(**args).first['count'],
          af2_high_value: Af2HighValueQuery.call(**args).first['count'],
          af2_disk: Af2DiskQuery.call(**args).first['count'],
          written_reasons: WrittenReasonsQuery.call(**args).first['count']
        }
      end

      def args
        { scheme: @scheme, day: @day }
      end
    end
  end
end
