require 'csv'

class OffenceMigration

  def initialize
    file_path = Rails.root.join('lib', 'assets', 'data', 'offence_to_full_offence_mappings.csv')
    csv_file = File.open(file_path, 'r:ISO-8859-1')
    @csv = CSV.parse(csv_file, headers: true)
    @conn = ActiveRecord::Base.connection
  end


  def up
    ap "TRANSFORMATION of offence data"
    store_old_offences
    create_new_offences
    update_claim_offences
    update_claim_misc_offences
    cleanup
  end

  def down
    # raise RunTimeError, 'irreversible data migration.'
    ap "REVERTING DATA MIGRATION - NOTE this is a convenience function and will not update any claim offence_id"
    Offence.delete_all
    Offence.connection.execute('ALTER SEQUENCE offences_id_seq RESTART WITH 1')
    load File.join(Rails.root, 'db', 'seeds', 'offences.rb')
  end

  def store_old_offences
    ActiveRecord::Base.connection.execute("CREATE TABLE old_offences AS SELECT * FROM offences WITH DATA;")
  end

  def create_new_offences
    Offence.delete_all
    Offence.connection.execute('ALTER SEQUENCE offences_id_seq RESTART WITH 1')
    load File.join(Rails.root, 'db', 'seeds', 'full_offences.rb')
  end

private

  def mappings_csv
    @csv
  end

  def map_row(row)
    mappings = {}
    mappings[:old_desc] = row[0].strip
    mappings[:new_desc] = row[1].strip
    mappings[:new_act]  = row[2].strip
    mappings
  end

  def update_claim_offences
    mappings_csv.each do |row|
      map = map_row(row)
      sql = "SELECT * FROM old_offences o WHERE o.description = '#{map[:old_desc]}'"
      old_offence = old_offence_query_one(sql)
      new_offence = Offence.find_by(description: "#{map[:new_desc]} (#{map[:new_act]})")

      Claim.where(offence_id: old_offence['id']).update_all(offence_id: new_offence.id)
      ap "UPDATE claims SET offence_id = #{new_offence.id} WHERE offence_id = #{old_offence['id']};"
    end
  end

  def old_offence_query_one(sql)
    result = @conn.execute(sql)
    raise "Transformation Error: #{result.to_a.count} offence records found for #{old_offence_description}" if result.to_a.count != 1
    result.to_a[0]
  end

  def update_claim_misc_offences
    ('A'..'K').each do |letter|
      offence_class = OffenceClass.find_by(class_letter: letter)
      sql = "SELECT * FROM old_offences o WHERE o.description = 'Miscellaneous/other' and o.offence_class_id = #{offence_class.id}"
      old_offence = old_offence_query_one(sql)
      new_offence = Offence.find_by(offence_class: offence_class, description: 'Miscellaneous/other')

      Claim.where(offence_id: old_offence['id']).update_all(offence_id: new_offence.id)
      ap "UPDATE claims SET offence_id = #{new_offence.id} WHERE offence_id = #{old_offence['id']};"
    end
  end

  def cleanup
    @conn.execute("DROP TABLE old_offences;")
  end

end
