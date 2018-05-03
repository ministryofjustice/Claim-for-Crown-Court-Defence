class AddGrantingBodyToRepresentationOrders < ActiveRecord::Migration[4.2]
  def change
    add_column :representation_orders, :granting_body, :string
  end
end
