class AddNewDataFieldsToOffence < ActiveRecord::Migration[4.2]
  def change
    add_column :offences, :contrary, :string
    add_column :offences, :year_chapter, :string
  end
end
