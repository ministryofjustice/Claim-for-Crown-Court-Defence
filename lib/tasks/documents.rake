namespace :documents do
  desc 'Copy all message attachment to message attachments.'
  task :duplicate_message_attachment => :environment do
    message = Message.last
    puts "Duplicating attachment of message ##{message.id}..."

    existing_attachment = message.attachments.find_by(blob: message.attachment.blob)
    if existing_attachment
      puts "Attachment #{existing_attachment.blob.filename} already exists in the database with ID #{existing_attachment.id}."
    else
      new_attachment = message.attachments.attach(message.attachment.blob)
      puts "Attachment #{new_attachment.blob.filename} is duplicated in the database."
    end
  end
end
