class AddUuids < ActiveRecord::Migration[4.2]
  def change
    add_column :advocates,              :uuid, :uuid, default: 'uuid_generate_v4()', index: true
    add_column :chambers,               :uuid, :uuid, default: 'uuid_generate_v4()', index: true
    add_column :claims,                 :uuid, :uuid, default: 'uuid_generate_v4()', index: true
    add_column :dates_attended,         :uuid, :uuid, default: 'uuid_generate_v4()', index: true
    add_column :defendants,             :uuid, :uuid, default: 'uuid_generate_v4()', index: true
    add_column :documents,              :uuid, :uuid, default: 'uuid_generate_v4()', index: true
    add_column :expenses,               :uuid, :uuid, default: 'uuid_generate_v4()', index: true
    add_column :fees,                   :uuid, :uuid, default: 'uuid_generate_v4()', index: true
    add_column :representation_orders,  :uuid, :uuid, default: 'uuid_generate_v4()', index: true
  end
end
