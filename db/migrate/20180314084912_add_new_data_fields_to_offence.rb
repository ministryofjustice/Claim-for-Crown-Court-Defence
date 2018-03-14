class AddNewDataFieldsToOffence < ActiveRecord::Migration
  def change
    add_column :offences, :contrary, :string
    add_column :offences, :year_chapter, :string
  end
end
