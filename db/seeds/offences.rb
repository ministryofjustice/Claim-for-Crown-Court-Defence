require 'csv'

file_path = Rails.root.join('lib', 'assets', 'data', 'offences.csv')
csv_file = File.open(file_path, 'r:ISO-8859-1')
csv = CSV.parse(csv_file, headers: true)

csv = csv.select { |r| !r[2].nil? }

csv.each do |row|
  class_letter = row[2].first.upcase
  description = row[0].strip
  offence_class = OffenceClass.find_by(class_letter: class_letter)
  Offence.find_or_create_by!(offence_class: offence_class, description: description)
end

('A'..'K').each do |letter|
  offence_class = OffenceClass.find_by(class_letter: class_letter)
  Offence.find_or_create_by!(offence_class: offence_class, description: 'Other')
end
