require 'csv'

fee_categories = {}
FeeCategory.all.each do |rec|
  fee_categories[rec.abbreviation] = rec
end

file_path = Rails.root.join('lib', 'assets', 'data', 'fee_types.csv')
data = CSV.read(file_path)
data.shift

data.each do |row|
  cat, description, code, max_amount = row
  max_amount = nil if max_amount == ''
  FeeType.find_or_create_by!(fee_category: fee_categories[cat], description: description, code: code, max_amount: max_amount)
end
