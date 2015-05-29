require 'csv'

fee_categories = {}
FeeCategory.all.each do |rec|
  fee_categories[rec.abbreviation] = rec
end

FeeType.delete_all

file_path = Rails.root.join('lib', 'assets', 'data', 'fee_types.csv')
data = CSV.read(file_path)
data.shift

data.each do |row|
  cat, description, code = row
  FeeType.create!(fee_category: fee_categories[cat], description: description, code: code)
end
  