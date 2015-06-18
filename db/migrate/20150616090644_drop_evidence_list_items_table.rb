class DropEvidenceListItemsTable < ActiveRecord::Migration
  def up
    drop_table :evidence_list_items
  end

  def down
    create_table :evidence_list_items do |t|
      t.string :description, null: false
      t.integer :item_order, null: false
    end

    add_index :evidence_list_items, :description, unique: true, name: 'evidence_list_items_description_uni'
    add_index :evidence_list_items, :item_order, unique: true, name: 'evidence_list_items_item_order_uni'
  end
end
