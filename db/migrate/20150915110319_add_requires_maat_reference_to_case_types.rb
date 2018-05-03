class AddRequiresMaatReferenceToCaseTypes < ActiveRecord::Migration[4.2]
  def change
    add_column :case_types, :requires_maat_reference, :boolean, default: false
  end
end
