class RemoveGrantingBodyFromRepresentationOrders < ActiveRecord::Migration
  def change
    remove_column :representation_orders, :granting_body
  end
end
