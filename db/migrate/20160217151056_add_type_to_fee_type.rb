class AddTypeToFeeType < ActiveRecord::Migration
  def up
    add_column :fee_types, :type, :string

    # This block only gets executed if the FeeCategory is still defined - it means we 
    # are migrating existing data.  Otherwise, we loading from scratch, and the seeds
    # will take care of specifiying the type
    populate_type if migrating_an_already_populated_database?
  end

  def down
    remove_column :fee_types, :type
  end

private
  def populate_type
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

  def migrating_an_already_populated_database?
    result_set = ActiveRecord::Base.connection.execute('select count(*) from fee_types')
    result_set[0]['count'] != "0"
  end
end
