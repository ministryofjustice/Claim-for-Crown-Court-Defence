class RemoveGrantingBodyFromRepresentationOrders < ActiveRecord::Migration[4.2]
  def change
    remove_column :representation_orders, :granting_body
  end
end
