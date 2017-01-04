class ConvertNullsToZeros < ActiveRecord::Migration
  def up
    {
      'expenses' => %w{ amount vat_amount },
      'fees' => %w{ amount },
      'disbursements' => %w{ net_amount vat_amount total }
    }.each do |table, fields|
      fields.each do |field|
        query = "UPDATE #{table} SET #{field} = 0.0 WHERE #{field} IS NULL"
        execute query
      end
    end
  end

  def down

  end
end
