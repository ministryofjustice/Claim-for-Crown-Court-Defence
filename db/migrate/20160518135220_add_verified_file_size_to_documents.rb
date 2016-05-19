class AddVerifiedFileSizeToDocuments < ActiveRecord::Migration
  def change
    add_column :documents, :verified_file_size, :integer
    add_column :documents, :file_path, :string
    add_column :documents, :verified, :boolean, default: false

    execute("UPDATE documents SET verified = 't'")
  end
end
