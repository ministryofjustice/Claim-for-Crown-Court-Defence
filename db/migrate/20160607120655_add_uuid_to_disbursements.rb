class AddUuidToDisbursements < ActiveRecord::Migration[4.2]
  def change
    add_column :disbursements, :uuid, :uuid, default: 'uuid_generate_v4()', index: true
  end
end
