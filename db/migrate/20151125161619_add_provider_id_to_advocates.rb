class AddProviderIdToAdvocates < ActiveRecord::Migration
  def change
    add_reference :advocates, :provider, index: true, foreign_key: true
  end
end
