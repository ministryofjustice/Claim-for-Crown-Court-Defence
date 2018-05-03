class AddApiKeyToChambers < ActiveRecord::Migration[4.2]
  def change
    add_column :chambers, :api_key, :uuid, default: 'uuid_generate_v4()', index: true
  end
end
