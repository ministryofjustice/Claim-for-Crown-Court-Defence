class AddRolesToProviders < ActiveRecord::Migration
  def change
    add_column :providers, :roles, :string

    Provider.all.each do |provider|
      provider.roles << 'agfs'
      provider.save!
    end
  end
end
