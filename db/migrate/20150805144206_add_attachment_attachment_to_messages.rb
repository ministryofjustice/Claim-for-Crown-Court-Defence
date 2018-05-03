class AddAttachmentAttachmentToMessages < ActiveRecord::Migration[4.2]
  def self.up
    change_table :messages do |t|
      t.attachment :attachment
    end
  end

  def self.down
    remove_attachment :messages, :attachment
  end
end
