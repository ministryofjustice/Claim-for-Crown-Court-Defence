class AddGrantingBodyToRepresentationOrders < ActiveRecord::Migration
  def change
    add_column :representation_orders, :granting_body, :string
  end
end
