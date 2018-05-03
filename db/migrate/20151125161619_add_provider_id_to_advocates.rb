class AddProviderIdToAdvocates < ActiveRecord::Migration[4.2]
  def change
    add_reference :advocates, :provider, index: true, foreign_key: true
  end
end
