require 'csv'

Fee::BaseFeeType.reset_column_information
Fee::BasicFeeType.reset_column_information
Fee::MiscFeeType.reset_column_information
Fee::FixedFeeType.reset_column_information

file_path = Rails.root.join('lib', 'assets', 'data', 'fee_types.csv')
data = CSV.read(file_path)
data.shift

data.each do |row|
  fee_type, description, code, max_amount, calculated = row
  klass = "Fee::#{fee_type.capitalize}FeeType".constantize
  calculated = calculated.downcase.strip == 'false' ? false : true
  max_amount = nil if max_amount.downcase.strip == 'nil'
  klass.find_or_create_by!(description: description, code: code, max_amount: max_amount, calculated: calculated, type: klass.to_s)
end
