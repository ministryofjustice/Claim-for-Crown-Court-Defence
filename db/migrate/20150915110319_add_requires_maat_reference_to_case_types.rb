class AddRequiresMaatReferenceToCaseTypes < ActiveRecord::Migration
  def change
    add_column :case_types, :requires_maat_reference, :boolean, default: false
  end
end
