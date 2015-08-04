class EnableUuid < ActiveRecord::Migration
  def up
    enable_extension 'uuid-ossp'
  end

  def down
    disable_extension 'uuid-ossp'
  end
end
