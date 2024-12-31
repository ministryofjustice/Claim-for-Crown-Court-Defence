namespace :documents do
  desc 'Copy all message attachment to message attachments.'
  task :duplicate_message_attachment => :environment do
    messages = Message.all
    puts "There are #{messages.count} messages."

    messages.each do |message|
      if message.attachment.attached?
        puts "Duplicating attachment of message ##{message.id}."
        attachment_blob = message.attachment.blob

        message.attachments.attach(attachment_blob)
        puts "Attachment #{attachment_blob.filename} is duplicated in the database."
      else
        puts "There is no attachment in message ##{message.id}."
      end
    end
    puts "duplicate_message_attachment done!"
  end
end
