class EnableUuid < ActiveRecord::Migration[4.2]
  def up
    enable_extension 'uuid-ossp'
  end

  def down
    disable_extension 'uuid-ossp'
  end
end
