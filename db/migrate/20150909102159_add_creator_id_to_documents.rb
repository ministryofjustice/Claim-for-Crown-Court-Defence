class AddCreatorIdToDocuments < ActiveRecord::Migration[4.2]
  def change
    add_column :documents, :creator_id, :integer
    add_index :documents, :creator_id
  end
end
