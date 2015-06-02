require 'csv'

file_path = Rails.root.join('lib', 'assets', 'data', 'crown_courts.csv')
data = CSV.read(file_path)

data.each do |row|
  name, code = row
  Court.find_or_create_by!(name: name, code: code, court_type: 'crown')
end