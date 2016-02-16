class ChangeTypeToAdvocateClaim < ActiveRecord::Migration
  def up
    ActiveRecord::Base.connection.execute "UPDATE claims SET type = 'Claim::AdvocateClaim'"
  end

  def down
    ActiveRecord::Base.connection.execute "UPDATE claims SET type = 'Claim::BaseClaim'"
  end
end
