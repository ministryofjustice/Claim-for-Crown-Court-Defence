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
max_id = 0


data.each do |row|
  begin
    id, description, code, unique_code, max_amount, calculated, fee_type, roles, parent_id, quantity_is_decimal = row
    max_id = [max_id, id.to_i].max
    klass = fee_type.constantize
    roles = roles.split(';')

    calculated = 'false' if calculated.nil?
    max_amount = 'nil' if max_amount.nil?
    calculated = calculated.downcase.strip == 'false' ? false : true
    max_amount = nil if max_amount.downcase.strip == 'nil'
    parent_id = parent_id.nil? ? nil : klass.find_by(description: parent_id.strip).try(:id)
    klass.create!(
      id: id,
      description: description,
      code: code,
      unique_code: unique_code,
      max_amount: max_amount,
      calculated: calculated,
      type: fee_type,
      parent_id: parent_id,
      roles: roles,
      quantity_is_decimal: quantity_is_decimal)
  rescue => err
    puts "***************** #{err.class}  #{err.message} *********** #{__FILE__}::#{__LINE__} ***********\n"
    puts err.backtrace
    puts row
  end
end

Fee::BaseFeeType.connection.execute("ALTER SEQUENCE fee_types_id_seq restart with #{max_id + 100}")
