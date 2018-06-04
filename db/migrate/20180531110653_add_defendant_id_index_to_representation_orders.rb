class AddDefendantIdIndexToRepresentationOrders < ActiveRecord::Migration[5.0]
  def change
    add_index :representation_orders, :defendant_id
  end
end
