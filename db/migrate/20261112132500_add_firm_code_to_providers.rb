class AddFirmCodeToProviders < ActiveRecord::Migration[8.1]
  def change
    add_column :providers, :firm_code, :integer
  end
end
