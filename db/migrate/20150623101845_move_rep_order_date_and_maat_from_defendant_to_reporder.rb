class MoveRepOrderDateAndMaatFromDefendantToReporder < ActiveRecord::Migration[4.2]
  def up
    add_column :representation_orders, :maat_reference, :string
    add_column :representation_orders, :representation_order_date, :date
    remove_column :defendants, :maat_reference
    remove_column :defendants, :representation_order_date
  end


  def down
    remove_column :representation_orders, :maat_reference
    remove_column :representation_orders, :representation_order_date
    add_column :defendants, :maat_reference, :string
    add_column :defendants, :representation_order_date, :datetime
  end
end
