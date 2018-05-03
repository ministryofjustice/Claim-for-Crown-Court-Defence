class ChangeTypeToAdvocateClaim < ActiveRecord::Migration[4.2]
  def up
    ActiveRecord::Base.connection.execute "UPDATE claims SET type = 'Claim::AdvocateClaim'"
  end

  def down
    ActiveRecord::Base.connection.execute "UPDATE claims SET type = 'Claim::BaseClaim'"
  end
end
