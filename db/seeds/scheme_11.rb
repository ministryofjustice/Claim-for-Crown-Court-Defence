require 'csv'
require Rails.root.join('db','seed_helper')
agfs_fee_scheme_ten = FeeScheme.find_or_create_by(name: 'AGFS', version: 10)
agfs_fee_scheme_ten.update(end_date: Settings.agfs_scheme_11_release_date.end_of_day-1.day)
agfs_fee_scheme_eleven = FeeScheme.find_or_create_by(name: 'AGFS', version: 11, start_date: Settings.agfs_scheme_11_release_date.beginning_of_day)

# Reset the ID so that ids of >=3000 will be scheme 11 offences
# This will allow us to add extra scheme 10 offences in an emergency while also providing an obvious break point
# for software vendors
ActiveRecord::Base.connection.set_pk_sequence!('offences', 3000) if Offence.order(:id).last.id < 3000

# create new offences (from csv)
file_name = ENV.fetch('RAILS_ENV', 'development') == 'test' ? 'scheme_11_offences_for_testing.csv' : 'scheme_11_offences.csv'
file_path = Rails.root.join('lib', 'assets', 'data', file_name)
csv_file = File.open(file_path, 'r:ISO-8859-1')
csv = CSV.parse(csv_file, headers: true)

module OffenceCSVRowExtensions
  def description
    self['description'].strip
  end

  def offence_category
    OffenceCategory.find_by(number: self['category'])
  end

  def offence_band
    OffenceBand.find_by(offence_category: offence_category, description: self['band'])
  end

  def contrary_to
    self['contrary_to']
  end

  def year_chapter
    self['year_chapter']
  end
end

class CSV::Row
  include OffenceCSVRowExtensions
end

csv.each do |row|
  SeedHelper.find_or_create_scheme_11_offence!(
    {
      offence_band: row.offence_band,
      description: row.description,
      contrary: row.contrary_to,
      year_chapter: row.year_chapter
    },
    agfs_fee_scheme_eleven
  )
end

# regenerate unique codes based on offence description and band where order is significant
require Rails.root.join('lib','data_migrator','offence_unique_code_migrator')
offences = agfs_fee_scheme_eleven.offences.joins(:offence_band).where(offence_class: nil).unscope(:order).order(Arel.sql('offences.description COLLATE "C", offences.contrary COLLATE "C", offence_bands.description COLLATE "C"'))
migrator = DataMigrator::OffenceUniqueCodeMigrator.new(relation: offences)
migrator.migrate!


