class AlterDocumentsAddAdvocateId < ActiveRecord::Migration
  def change
    change_table(:documents) do |t|
      t.references :advocate, index: true
    end
  end
end
