class RemoveSubjectFromMessage < ActiveRecord::Migration[4.2]
  def change
    remove_column :messages, :subject, :string
  end
end
