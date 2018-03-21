require 'csv'
require_relative '../offence_code_seeder_scheme_ten.rb'

lgfs_scheme_nine = FeeScheme.find_or_create_by(number: 9, name: 'LGFS', start_date: Date.new(2014, 03, 20).beginning_of_day)
agfs_scheme_nine = FeeScheme.find_or_create_by(number: 9, name: 'AGFS', start_date: Date.new(2012, 04, 01).beginning_of_day, end_date: Date.new(2018, 03, 31).end_of_day)
FeeScheme.find_or_create_by(number: 10, name: 'AGFS', start_date: Date.new(2012, 04, 01).beginning_of_day)

Offence.find_each do |offence|
  OffenceFeeScheme.find_or_create_by(offence: offence, fee_scheme: agfs_scheme_nine)
  OffenceFeeScheme.find_or_create_by(offence: offence, fee_scheme: lgfs_scheme_nine)
end

# create offence categories
OffenceCategory.find_or_create_by(number: 1, description: 'Murder/Manslaughter')
OffenceCategory.find_or_create_by(number: 2, description: 'Terrorism')
OffenceCategory.find_or_create_by(number: 3, description: 'Serious Violence')
OffenceCategory.find_or_create_by(number: 4, description: 'Sexual Offences (Children)')
OffenceCategory.find_or_create_by(number: 5, description: 'Sexual Offences (Adult)')
OffenceCategory.find_or_create_by(number: 6, description: 'Dishonesty Offences')
OffenceCategory.find_or_create_by(number: 7, description: 'Property Damage')
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

# create new offences (from csv)
agfs_fee_scheme_ten = FeeScheme.find_by(name: 'AGFS', number: '10')

file_path = Rails.root.join('lib', 'assets', 'data', 'scheme_10_offences.csv')
csv_file = File.open(file_path, 'r:ISO-8859-1')
csv = CSV.parse(csv_file, headers: true)

csv.each do |row|
  # row desc : Category,Band,Offence,Contrary to,Year and Chapter
  description = row[2].strip
  offence_category = OffenceCategory.find_by(number: row[0])
  offence_band = OffenceBand.find_by(offence_category: offence_category, description: row[1])
  unique_code = OffenceCodeSeederSchemeTen.new(description, offence_band.number.to_s.each_byte.to_a.join(''), row[3]).unique_code
  offence = Offence.find_or_create_by!(
    offence_band: offence_band,
    description: description,
    unique_code: unique_code,
    contrary: row[3],
    year_chapter: row[4]
  )
  OffenceFeeScheme.find_or_create_by(offence: offence, fee_scheme: agfs_fee_scheme_ten)
end