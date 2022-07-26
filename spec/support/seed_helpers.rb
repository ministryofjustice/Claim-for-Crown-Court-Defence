require 'rails_helper'
require File.expand_path(Rails.root.join('db', 'seeds', 'fee_types', 'csv_seeder'))

module SeedHelpers
  def seed_fee_schemes
    FeeScheme.find_or_create_by(name: 'LGFS', version: 9, start_date: Date.new(2014, 03, 20).beginning_of_day, end_date: Settings.lgfs_scheme_10_clair_release_date - 1.day)
    FeeScheme.find_or_create_by(name: 'LGFS', version: 10, start_date: Settings.lgfs_scheme_10_clair_release_date.beginning_of_day)
    FeeScheme.find_or_create_by(name: 'AGFS', version: 9, start_date: Date.new(2012, 04, 01).beginning_of_day, end_date: Date.new(2018, 03, 31).end_of_day)
    FeeScheme.find_or_create_by(name: 'AGFS', version: 10, start_date: Settings.agfs_fee_reform_release_date.beginning_of_day, end_date: Settings.agfs_scheme_11_release_date - 1.day)
    FeeScheme.find_or_create_by(name: 'AGFS', version: 11, start_date: Settings.agfs_scheme_11_release_date.beginning_of_day, end_date: Settings.clar_release_date.end_of_day - 1.day)
    FeeScheme.find_or_create_by(name: 'AGFS', version: 12, start_date: Settings.clar_release_date.beginning_of_day)
  end

  def seed_case_types
    load_seed 'case_types'
  end

  def destroy_case_types
    CaseType.destroy_all
  end

  def seed_case_stages
    load_seed 'case_stages'
  end

  def seed_fee_types
    Seeds::FeeTypes::CsvSeeder.new(dry_mode: false).call
  end

  def seed_expense_types
    load_seed 'expense_types'
  end

  def seed_disbursement_types
    load_seed 'disbursement_types'
  end

  private

  def load_seed(file)
    load Rails.root.join('db', 'seeds', "#{file.gsub('.rb', '')}.rb")
  end
end
