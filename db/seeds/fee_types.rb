require 'csv'
require Rails.root.join('db','seed_helper')
require Rails.root.join('db','seeds', 'fee_types', 'csv_seeder')

Fee::BaseFeeType.reset_column_information
Fee::BasicFeeType.reset_column_information
Fee::MiscFeeType.reset_column_information
Fee::FixedFeeType.reset_column_information
Fee::GraduatedFeeType.reset_column_information

dry_mode = ENV['SEEDS_DRY_MODE'].to_s.downcase.strip == 'true'

Seeds::FeeTypes::CsvSeeder.new(dry_mode: dry_mode).call
