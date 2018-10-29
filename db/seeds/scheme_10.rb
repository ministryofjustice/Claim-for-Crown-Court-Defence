# NOTE: this is NOT idempotent due to whitespace in the scheme 10 offence
# file. It has not been changed because it will create a difference with
# live data
require 'csv'
require Rails.root.join('db','seed_helper')

lgfs_scheme_nine = FeeScheme.find_or_create_by(name: 'LGFS', version: 9, start_date: Date.new(2014, 03, 20).beginning_of_day)
agfs_scheme_nine = FeeScheme.find_or_create_by(name: 'AGFS', version: 9, start_date: Date.new(2012, 04, 01).beginning_of_day, end_date: Date.new(2018, 03, 31).end_of_day)
agfs_fee_scheme_ten = FeeScheme.find_or_create_by(name: 'AGFS', version: 10, start_date: Date.new(2018, 04, 01).beginning_of_day)

Offence.where.not(offence_class: nil).each do |offence|
  OffenceFeeScheme.find_or_create_by(offence: offence, fee_scheme: agfs_scheme_nine)
  OffenceFeeScheme.find_or_create_by(offence: offence, fee_scheme: lgfs_scheme_nine)
end

# create offence categories
OffenceCategory.find_or_create_by(number: 1, description: 'Murder/Manslaughter')
OffenceCategory.find_or_create_by(number: 2, description: 'Terrorism')
OffenceCategory.find_or_create_by(number: 3, description: 'Serious Violence')
OffenceCategory.find_or_create_by(number: 4, description: 'Sexual Offences (children) – defendant or victim a child at the time of offence')
OffenceCategory.find_or_create_by(number: 5, description: 'Sexual Offences (Adult)')
OffenceCategory.find_or_create_by(number: 6, description: 'Dishonesty (to include Proceeds of Crime and Money Laundering)')
OffenceCategory.find_or_create_by(number: 7, description: 'Property Damage Offences')
OffenceCategory.find_or_create_by(number: 8, description: 'Offences Against the Public Interest')
OffenceCategory.find_or_create_by(number: 9, description: 'Drugs Offences')
OffenceCategory.find_or_create_by(number: 10, description: 'Driving Offences')
OffenceCategory.find_or_create_by(number: 11, description: 'Burglary and Robbery')
OffenceCategory.find_or_create_by(number: 12, description: 'Firearms Offences')
OffenceCategory.find_or_create_by(number: 13, description: 'Other Offences Against the Person')
OffenceCategory.find_or_create_by(number: 14, description: 'Exploitation and Human Trafficking Offences')
OffenceCategory.find_or_create_by(number: 15, description: 'Public Order Offences')
OffenceCategory.find_or_create_by(number: 16, description: 'Regulatory Offences')
OffenceCategory.find_or_create_by(number: 17, description: 'Standard Offences')

# create offence bands
[
  [1, 4],[2, 2], [3, 5], [4, 3], [5, 3], [6, 5], [7, 3], [8, 1], [9, 7],
  [10, 1], [11, 2], [12, 3], [13, 1], [14, 1], [15, 3], [16, 3], [17, 1]
].each do |k,v|
  category = OffenceCategory.find_by(number: k)
  1.upto(v) do |i|
    OffenceBand.find_or_create_by(offence_category: category, number: i, description: "#{k}.#{i}")
  end
end

# Reset the ID so that ids of >=1000 will be scheme 10 offences
# This will allow us to add extra scheme 9 offences in an emergency while also providing an obvious break point
# for software vendors
ActiveRecord::Base.connection.set_pk_sequence!('offences', 1000) if Offence.order(:id).last.id < 1000

# create new offences (from csv)
file_path = Rails.root.join('lib', 'assets', 'data', 'scheme_10_offences.csv')
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
  offence = SeedHelper.find_or_create_scheme_10_offence!(
    offence_band: row.offence_band,
    description: row.description,
    contrary: row.contrary_to,
    year_chapter: row.year_chapter
  )
end

# regenerate unique codes based on offence description and band where order is significant
require Rails.root.join('lib','data_migrator','offence_unique_code_migrator')
offences = Offence.joins(:offence_band).where(offence_class: nil).unscope(:order).order('offences.description COLLATE "C", offences.contrary COLLATE "C", offence_bands.description COLLATE "C"')
migrator = DataMigrator::OffenceUniqueCodeMigrator.new(relation: offences)
migrator.migrate!


