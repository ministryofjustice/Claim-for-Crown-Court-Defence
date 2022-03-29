module Tasks
  module RakeHelpers
    module Storage
      def self.s3_files(interactive)
        Aws.config[:credentials] = Aws::Credentials.new(Settings.aws.s3.access, Settings.aws.s3.secret)
        s3 = Aws::S3::Client.new
        data = {
          attached: {
            rows: [],
            total: 0,
            size: 0
          },
          orphaned: {
            rows: [],
            total: 0,
            size: 0
          }
        }

        s3.list_objects(bucket: Settings.aws.s3.bucket).each_with_index do |response, i|
          contents = response.contents
          blobs = ActiveStorage::Blob.where(key: contents.map(&:key)).index_by(&:key)
          keys = blobs.keys
          good, bad = contents.partition { |c| keys.include? c.key }

          self.collate data[:attached], good, blobs
          self.collate data[:orphaned], bad

          puts "#{i+1}000 processed"
          if interactive
            print 'Continue? [Y/n] '
            break if $stdin.gets.strip.downcase.first == 'n'
          end
        end

        data
      end

      private

      def self.collate(data, new_data, blobs = nil)
        data[:total] += new_data.count
        data[:size] += new_data.sum { |content| content.size }
        data[:rows] += new_data.map do |content|
          (
            blobs.nil? ? [] : [
              blobs[content.key].id,
              blobs[content.key].filename,
              blobs[content.key].attachments.count
            ]
          ) + [
            content.key,
            content.last_modified,
            content.size
          ]
        end
      end
    end
  end
end
