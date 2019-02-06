module DatabaseHousekeeping
	def clean_database
    raise 'Warning: do not use in non-test enviroments' unless Rails.env.test?
    truncate_application_tables
  end

  # This excludes non application tables (schema_migrations, ar_internal_metadata)
  # we exclude vat_rates as they are created/destroyed in a before/after(:suite) hook
  def application_tables
    exclusions = %W[vat_rates]
    ApplicationRecord.descendants.map(&:table_name).uniq.sort - exclusions
  end

  def truncate_application_tables
    conn = ActiveRecord::Base.connection
    conn.disable_referential_integrity do
      application_tables.each do |table_name|
        conn.execute("TRUNCATE TABLE \"#{table_name}\" RESTART IDENTITY CASCADE")
      end
    end
  end

  def report_record_counts
    models = ApplicationRecord.descendants
    models.each do |model|
      puts "#{model} count: #{model.count}"
    end
  end
end
