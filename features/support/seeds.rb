module CucumberSeeds
  TABLES = %w[
    vat_rates courts offence_classes offences case_types case_stages fee_types certification_types expense_types
    disbursement_types offence_bands offence_categories offence_fee_schemes fee_schemes establishments
  ].freeze

  SEED_FILES = %w[
    courts offence_classes offences scheme_10 scheme_11 scheme_12 case_types case_stages fee_types
    certification_types disbursement_types expense_types vat_rates establishments lgfs_scheme_10
    scheme_13 scheme_14 scheme_15 scheme_16 agfs_scheme_cleaner lgfs_scheme_11 scheme_17
  ].freeze

  def self.preseeded?
    ENV['CUCUMBER_PRESEEDED'] == 'true'
  end

  def self.load!
    ActiveRecord::Base.connection.reset_pk_sequence!('offences')
    SEED_FILES.each { |file| load Rails.root.join('db', 'seeds', "#{file}.rb") }
  end

  def self.verify!
    connection = ActiveRecord::Base.connection
    TABLES.each do |table|
      next if connection.select_value("SELECT 1 FROM #{connection.quote_table_name(table)} LIMIT 1")

      raise "Cucumber seed snapshot is missing data in #{table}"
    end
  end
end
