module ThinkstCanary
  module Token
    class PdfAcrobatReader < FileBased
      def initialize(**kwargs)
        @file_key = :pdf
        @mime = 'application/pdf'

        super
      end
    end
  end
end
