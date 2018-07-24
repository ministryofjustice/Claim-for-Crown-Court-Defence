require 'rails_helper'
require File.expand_path(Rails.root.join('db','seeds','fee_types','csv_seeder'))

module SeedHelpers
  def seed_fee_schemes
    # TODO: remove if not needed
    # FeeScheme.find_by(name: 'LGFS', version: 9) || create(:fee_scheme, :lgfs_nine)
    # FeeScheme.find_by(name: 'AGFS', version: 9) || create(:fee_scheme, :agfs_nine)
    # FeeScheme.find_by(name: 'AGFS', version: 10) || create(:fee_scheme, :agfs_ten)

    # TODO: these should be in a separate seedfile that is just loaded here - cirrently they are in scheme_ten.rb seed file
    FeeScheme.find_or_create_by(name: 'LGFS', version: 9, start_date: Date.new(2014, 03, 20).beginning_of_day)
    FeeScheme.find_or_create_by(name: 'AGFS', version: 9, start_date: Date.new(2012, 04, 01).beginning_of_day, end_date: Date.new(2018, 03, 31).end_of_day)
    FeeScheme.find_or_create_by(name: 'AGFS', version: 10, start_date: Date.new(2018, 04, 01).beginning_of_day)
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
