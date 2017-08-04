module Stats
  module Collector
    class ClaimCreationSourceCollector < BaseCollector
      CLAIM_SOURCES = {
        web:  %w[web],
        api:  %w[api api_web_edited],
        json: %w[json_import json_import_web_edited]
      }.freeze

      def collect
        CLAIM_SOURCES.each do |name, sources|
          num_creations_by_source = created_claims_for_day_and_source(sources)
          Statistic.create_or_update(@date, "creations_source_#{name}", Claim::BaseClaim, num_creations_by_source)
        end
      end

      private

      def created_claims_for_day_and_source(source)
        Claim::BaseClaim.active.where(created_at: @date.beginning_of_day..@date.end_of_day).where(source: source).count
      end
    end
  end
end
