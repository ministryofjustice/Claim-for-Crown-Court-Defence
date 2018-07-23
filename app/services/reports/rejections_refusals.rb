module Reports
  class RejectionsRefusals
    NAME = 'rejections_refusals'.freeze
    COLUMNS = %w[provider_name provider_type supplier_number
                 claims_issued rejections rejections_percent refusals refusals_percent
                 rejections_refusals_percent].freeze

    def self.call
      new.call
    end

    def call
      Stats::MIData.connection.execute(query).to_a
    end

    private

    def query
      %{select provider_name, provider_type, supplier_number, claims_issued,
        rejections, cast(rejections as decimal)/NULLIF(claims_issued, 0) as rejections_percent,
        refusals, cast(refusals as decimal)/NULLIF(claims_issued, 0) as refusals_percent,
        cast((rejections+refusals) as decimal)/NULLIF(claims_issued, 0) as rejections_refusals_percent
      FROM (#{aggregated_query}) as aq
      }
    end

    def aggregated_query
      %{SELECT provider_name,
      provider_type,
      supplier_number,
      count(*) as claims_issued,
      count(CASE WHEN rejections > 0 THEN 1 END) as rejections,
      sum(refusals) as refusals
      FROM mi_data
      GROUP BY provider_name, provider_type, supplier_number}
    end
  end
end
