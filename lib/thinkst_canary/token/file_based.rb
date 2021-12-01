module ThinkstCanary
  module Token
    class FileBased < Base
      def initialize(**kwargs)
        @file = kwargs[:file]

        super(**kwargs)
      end

      private

      def create_options
        super.merge(@file_key => doc)
      end

      def doc
        @doc ||= Faraday::UploadIO.new(@file, @mime)
      end
    end
  end
end
