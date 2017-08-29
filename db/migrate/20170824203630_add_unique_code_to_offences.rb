class AddUniqueCodeToOffences < ActiveRecord::Migration
  def up
    add_column :offences, :unique_code, :string, default: 'anyoldrubbish', null: false
    Rake::Task['data:migrate:offence_unique_code'].invoke
    add_index :offences, :unique_code, unique: true
  end

  def down
    remove_index :offences, :unique_code
    remove_column :offences, :unique_code, :string, null: false
  end
end
