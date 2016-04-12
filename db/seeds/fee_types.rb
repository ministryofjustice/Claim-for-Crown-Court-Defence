require 'csv'
require Rails.root.join('db','seed_helper')

Fee::BaseFeeType.reset_column_information
Fee::BasicFeeType.reset_column_information
Fee::MiscFeeType.reset_column_information
Fee::FixedFeeType.reset_column_information
Fee::GraduatedFeeType.reset_column_information

file_path = Rails.root.join('lib', 'assets', 'data', 'fee_types.csv')
data = CSV.read(file_path)
data.shift


data.each do |row|
  begin
    fee_type, roles, description, code, max_amount, calculated, parent = row
    klass = "Fee::#{fee_type.capitalize}FeeType".constantize
    roles = roles.split(';')
    calculated = 'false' if calculated.nil?
    max_amount = 'nil' if max_amount.nil?
    calculated = calculated.downcase.strip == 'false' ? false : true
    max_amount = nil if max_amount.downcase.strip == 'nil'
    parent_id = parent.nil? ? nil : klass.find_by(description: parent.strip).try(:id)
    record = klass.find_by(description: description)
    if record
      record.update!(roles: roles, description: description, code: code, max_amount: max_amount, calculated: calculated, type: klass.to_s, parent_id: parent_id)
    else
      klass.create!(roles: roles, description: description, code: code, max_amount: max_amount, calculated: calculated, type: klass.to_s, parent_id: parent_id)
    end
  rescue => err
    puts ">>>>>>>>>>>>>> ERROR #{err.class}  #{err.message} <<<<<<<< #{__FILE__}::#{__LINE__} <<<<<<<<<\n"
    puts row
  end
end
