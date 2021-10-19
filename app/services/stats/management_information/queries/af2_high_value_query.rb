# frozen_string_literal: true

# https://docs.google.com/spreadsheets/d/1LgECNzbhOJ0MPS-2jbsXVyvtS2Q2TnjDQ4o42tyhU_g/edit#gid=1744254165
# Where scheme = AGFS
# And Where submission type = redetermination
# And Where originally submitted = DATE specified for this lookup *
# And Where disk evidence = no
# And Where claim total > 20,000
#
module Stats
  module ManagementInformation
    class Af2HighValueQuery
      include JourneyQueryable
      include ClaimTypeQueryable

      attr_reader :scheme

      def self.call(options = {})
        new(options).call
      end

      def initialize(options = {})
        @scheme = options[:scheme]&.to_s&.upcase
        @day = options[:day]
        raise ArgumentError, 'scheme must be "agfs" or "lgfs"' if @scheme.present? && %w[AGFS LGFS].exclude?(@scheme)
      end

      def call
        prepare
        ActiveRecord::Base.connection.execute(query)
      end

      private

      def prepare
        ActiveRecord::Base.connection.execute(drop_journeys_func)
        ActiveRecord::Base.connection.execute(create_journeys_func)
      end

      def query
        <<~SQL
          WITH journeys AS (
            #{journeys_query}
          )
          SELECT count(*)
          FROM journeys j
          WHERE j.scheme = '#{@scheme}'
          AND date_trunc('day', j.original_submission_date) = '#{@day}'
          AND j.journey -> 0 ->> 'to' = 'redetermination'
          AND NOT j.disk_evidence
          AND j.claim_total::float >= 20000.00
        SQL
      end
    end
  end
end
