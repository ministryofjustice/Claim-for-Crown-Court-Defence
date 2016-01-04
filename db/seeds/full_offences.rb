require 'csv'

file_path = Rails.root.join('lib', 'assets', 'data', 'full_offences.csv')
csv_file = File.open(file_path, 'r:ISO-8859-1')
csv = CSV.parse(csv_file, headers: true)

csv.each do |row|
  # NOTE strip out the asterix on classes of offence that do not appear in the remuneration regulation 2013 table
  class_letters = row[2].upcase.strip.gsub(/\*/,'').split('/')

  class_letters.each do |class_letter|
    description_with_act= row[0].strip + " (#{row[1].strip})"
    offence_class = OffenceClass.find_by(class_letter: class_letter)
    Offence.find_or_create_by!(offence_class: offence_class, description: description_with_act)
  end
end

# create catch-all offences for each class for backward compatability
('A'..'K').each do |letter|
  offence_class = OffenceClass.find_by(class_letter: letter)
  Offence.find_or_create_by!(offence_class: offence_class, description: 'Miscellaneous/other')
end
