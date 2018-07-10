module Reports
  class FetchProvidersCarTravelData
    def self.call(options = {})
      new(options).call
    end

    def initialize(options)
      @options = options
    end

    def call
      # NOTE: outputs something in the following format:
      # rubocop:disable Metrics/LineLength
      # => [{"frequency"=>1, "location"=>"Lake Lavern", "reason_id"=>5, "provider_name"=>"Test firm A", "supplier_number"=>"2A333Z", "user_email"=>"litigator@example.com"},
      # {"frequency"=>1, "location"=>"Lake Sydnieville", "reason_id"=>3, "provider_name"=>"Test firm A", "supplier_number"=>"2A333Z", "user_email"=>"litigator@example.com"},
      # {"frequency"=>1, "location"=>"Luton", "reason_id"=>1, "provider_name"=>"Test firm A", "supplier_number"=>"1A222Z", "user_email"=>"litigatoradmin@example.com"}]
      # rubocop:enable Metrics/LineLength
      ActiveRecord::Base.connection.execute(query.to_sql).to_a
    end

    private

    def columns
      [
        'count(*) as frequency',
        'users.email as user_email',
        'expenses.location',
        'expenses.reason_id',
        'providers.name as provider_name',
        'claims.supplier_number as supplier_number'
      ]
    end

    def query
      Expense.select(columns.join(','))
             .joins(claim: { creator: %i[provider user] })
             .joins(:expense_type)
             .where(claims: { type: Claim::BaseClaim.lgfs_claim_types, source: 'web' })
             .where(cs[:state].not_eq('draft'))
             .where(expense_types: { name: 'Car travel' })
             .group('users.email, expenses.location, expenses.reason_id, providers.name, claims.supplier_number')
    end

    def cs
      Claim::BaseClaim.arel_table
    end
  end
end
