require 'csv'

fee_categories = {}
FeeCategory.all.each do |rec|
  fee_categories[rec.abbreviation] = rec
end

file_path = Rails.root.join('lib', 'assets', 'data', 'fee_types.csv')
data = CSV.read(file_path)
data.shift

data.each do |row|
  cat, description, code, max_amount, calculated = row
  calculated = calculated.downcase.strip == 'false' ? false : true
  max_amount = nil if max_amount.downcase.strip == 'nil'
  FeeType.find_or_create_by!(fee_category: fee_categories[cat], description: description, code: code, max_amount: max_amount, calculated: calculated)
end
