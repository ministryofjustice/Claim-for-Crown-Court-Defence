require 'rails_helper'
require File.expand_path(Rails.root.join('db','seeds','fee_types','csv_seeder'))

module SeedHelpers
  def seed_fee_schemes
    FeeScheme.find_by(name: 'LGFS', version: 9) || create(:fee_scheme, :lgfs_nine)
    FeeScheme.find_by(name: 'AGFS', version: 9) || create(:fee_scheme, :agfs_nine)
    FeeScheme.find_by(name: 'AGFS', version: 10) || create(:fee_scheme, :agfs_ten)
  end

  def seed_fee_types
    Seeds::FeeTypes::CsvSeeder.new(dry_mode: false).call
  end

  def seed_expense_types
    load_seed 'expense_types'
  end

  private

  def load_seed file
    load Rails.root.join('db', 'seeds', "#{file.gsub('.rb', '')}.rb")
  end
end
