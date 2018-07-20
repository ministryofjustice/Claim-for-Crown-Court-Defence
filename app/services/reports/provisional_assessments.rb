module Reports
  class ProvisionalAssessments
    NAME = 'provisional_assessment'.freeze
    COLUMNS = %w[provider_name provider_type provider_claims supplier_number
                 supplier_claims claimed authorised percent].freeze

    def self.call
      new.call
    end

    def call
      Stats::MIData.connection.execute(query).to_a
    end

    private

    def query
      %{SELECT supplier_data.provider_name, provider_type,
        provider_claims, supplier_number,
        supplier_claims, claimed,
        authorised, percent
      FROM (#{suppliers_totals_query}) as supplier_data
      INNER JOIN (#{providers_totals_query}) as provider_data
      ON (supplier_data.provider_name = provider_data.provider_name)}
    end

    def providers_totals_query
      %{SELECT provider_name, count(provider_name) as provider_claims FROM mi_data GROUP BY provider_name}
    end

    def suppliers_totals_query
      %{SELECT provider_name,
      provider_type,
      supplier_number,
      count(supplier_number) as supplier_claims,
      sum(amount_claimed) as claimed,
      sum(amount_authorised) as authorised,
      sum(amount_authorised)/NULLIF(sum(amount_claimed), 0) as percent
      FROM mi_data
      GROUP BY provider_name, provider_type, supplier_number}
    end
  end
end
