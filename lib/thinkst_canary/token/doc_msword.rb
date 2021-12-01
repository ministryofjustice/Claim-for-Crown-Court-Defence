module ThinkstCanary
  module Token
    class DocMsword < FileBased
      def initialize(**kwargs)
        @file_key = :doc
        @mime = 'application/vnd.openxmlformats-officedocument.wordprocessingml.document'

        super(**kwargs)
      end
    end
  end
end
