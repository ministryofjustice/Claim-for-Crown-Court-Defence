namespace :audit do

  desc 'display list of claims with nulls in numeric fields'
  task nulls: :environment do
    fields = %w{ fees_total expenses_total disbursements_total total vat_amount fees_vat expenses_vat disbursements_vat }
    fields_clause = fields.map{ |f| "#{f} is null"}.join(' or ')
    query = "select id, #{fields.join(', ')} from claims where #{fields_clause}"
    result_set = ActiveRecord::Base.connection.execute(query)
    puts "#{result_set.ntuples} found with nulls."
    str = ''
    result_set.each do |row|
      str += "Claim #{row['id']} has nil values:\n"
      row.select{ |f, v| v.nil? }.each do |field, _value|
        str += "    #{field}\n"
      end
    end
    puts str
  end
end