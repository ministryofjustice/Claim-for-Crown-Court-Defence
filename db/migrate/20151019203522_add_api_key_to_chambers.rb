class AddApiKeyToChambers < ActiveRecord::Migration
  def change
    add_column :chambers, :api_key, :uuid, default: 'uuid_generate_v4()', index: true
  end
end
