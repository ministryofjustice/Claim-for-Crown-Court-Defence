require 'csv'

module Tasks
  module RakeHelpers
    module RakeUtils
      def continue?(prompt = nil)
        prompt = prompt || 'Continue?'
        printf prompt.yellow + ": [no/yes] "
        response = STDIN.gets.chomp
        exit unless response.match?(/^(y|yes)$/i)
        true
      end

      def shell_working message = 'working', &block
        spinner = TTY::Spinner.new("[:spinner] #{message}")
        spinner.run do
          yield
          spinner.success
        end
      end

      def compress_file(filename)
        shell_working "compressing file #{filename}" do
          system "gzip -3 -f #{filename}"
        end
        "#{filename}.gz"
      end

      def decompress_file(filename)
        shell_working "decompressing file #{filename}" do
          system "gunzip #{filename}"
        end
      end

      def production_protected
        raise 'This operation was aborted because the result might destroy production data' if Rails.host.production?
      end

      def csv_writer(filename, data:, headers: nil)
        CSV.open(filename, 'w') do |csv|
          csv << headers if headers
          data.each { |row| csv << row }
        end
      end
    end
  end
end
