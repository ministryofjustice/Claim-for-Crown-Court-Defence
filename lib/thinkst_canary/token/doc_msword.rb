module ThinkstCanary
  module Token
    class DocMsword < Base
      def initialize(**kwargs)
        @kind = 'doc-msword'
        @file = kwargs[:file]

        super(**kwargs)
      end

      private

      def create_options
        super.merge(doc: doc)
      end

      def doc
        @doc ||= Faraday::UploadIO.new(@file, 'application/vnd.openxmlformats-officedocument.wordprocessingml.document')
      end
    end
  end
end
