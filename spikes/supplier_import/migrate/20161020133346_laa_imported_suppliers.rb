
class LaaImportedSuppliers < ActiveRecord::Migration
  def change
    create_table :laa_imported_suppliers do |t|
      t.string :accCode, index: true, null: false
      t.string :accName, null: false
      t.datetime :dateCreated
      t.string :userCreated
      t.datetime :dateModified
      t.string :userModified
      t.string :regiRegion
      t.string :parent
      t.string :sutySuppType
      t.string :vatReg
      t.string :extAcRef
      t.string :address1
      t.string :address2
      t.string :address3
      t.string :address4
      t.string :county
      t.string :postCode
      t.string :country
      t.string :highRisk
      t.string :pstyHigh

      t.timestamps
    end
  end
end
