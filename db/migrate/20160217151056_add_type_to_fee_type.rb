class AddTypeToFeeType < ActiveRecord::Migration
  def up
    add_column :fee_types, :type, :string

    categories = {}

    FeeCategory.all.each { |cat| categories[cat.id] = cat.abbreviation }

    # do it this way so that we can run it before and after we've changed the class name
    fee_types = ActiveRecord::Base.connection.execute('SELECT * FROM fee_types')
    fee_types.each do |ft|
      catid = ft['fee_category_id'].to_i
      type = case categories[catid]
      when 'BASIC'
        'Fee::BasicFeeType'
      when 'FIXED'
        'Fee:FixedFeeType'
      when 'MISC'
        'Fee::MiscFeeType'
      end
      ActiveRecord::Base.connection.execute("UPDATE fee_types SET type = '#{type}' WHERE id = #{ft['id']}")
    end
  end

  def down
    remove_column :fee_types, :type
  end
end
