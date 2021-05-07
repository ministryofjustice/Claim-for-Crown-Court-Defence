require 'tasks/rake_helpers/storage'

namespace :storage do
  include ActionView::Helpers::NumberHelper

  desc 'Review S3 files'
  task :s3_status, [:interactive] => :environment do |_task, args|
    file_lists = Storage.s3_files(args[:interactive] == 'interactive')

    CSV.open('tmp/s3_files.csv', 'wb') do |csv|
      csv << %w[Blob Filename Attachments Key Modified Size]
      file_lists[:attached][:rows].sort_by { |row| row[3] }.each { |row| csv << row }
    end

    CSV.open('tmp/s3_orphaned_files.csv', 'wb') do |csv|
      csv << %w[Key Modified Size]
      file_lists[:orphaned][:rows].sort_by { |row| row[3] }.each { |row| csv << row }
    end

    File.open('tmp/s3_summary.txt', 'w') do |file|
      file.puts "Files attached to Active Storage attachments: #{file_lists[:attached][:total]}"
      file.puts "Size of attached files: #{number_to_human_size(file_lists[:attached][:size])}"
      file.puts "Files not attached to Active Storage attachments: #{file_lists[:orphaned][:total]}"
      file.puts "Size of non-attached files: #{number_to_human_size(file_lists[:orphaned][:size])}"
    end
  end
end
