class AlterDocumentsAddAdvocateId < ActiveRecord::Migration[4.2]
  def change
    change_table(:documents) do |t|
      t.references :advocate, index: true
    end
  end
end
