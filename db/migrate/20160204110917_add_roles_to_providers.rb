class AddRolesToProviders < ActiveRecord::Migration[4.2]
  def change
    add_column :providers, :roles, :string

    Provider.all.each do |provider|
      provider.roles << 'agfs'
      provider.save!
    end
  end
end
