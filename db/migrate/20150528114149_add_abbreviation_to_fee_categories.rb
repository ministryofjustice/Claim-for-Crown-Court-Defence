class AddAbbreviationToFeeCategories < ActiveRecord::Migration
  def change
    add_column :fee_categories, :abbreviation, :string
  end
end
