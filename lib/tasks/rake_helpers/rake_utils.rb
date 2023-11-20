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
        ShellSpinner message do
          yield
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
    end
  end
end
