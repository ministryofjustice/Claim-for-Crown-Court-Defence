module DatabaseHousekeeping
  def clean_database
    raise 'Warning: do not use in non-test enviroments' unless Rails.env.test?
    truncate_application_tables
  end

  # This excludes non application tables (schema_migrations, ar_internal_metadata)
  # we also exclude vat_rates as they are created/destroyed in a before/after(:suite) hook
  def application_tables
    exclusions = %w[schema_migrations ar_internal_metadata vat_rates fee_schemes]
    ActiveRecord::Base.connection.tables.uniq.sort - exclusions
  end

  def truncate_application_tables
    conn = ActiveRecord::Base.connection
    conn.disable_referential_integrity do
      application_tables.each do |table_name|
        conn.execute("TRUNCATE TABLE \"#{table_name}\" RESTART IDENTITY CASCADE")
      end
    end
  end
end
