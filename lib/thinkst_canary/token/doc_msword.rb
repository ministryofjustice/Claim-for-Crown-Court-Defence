module ThinkstCanary
  module Token
    class DocMsword < Base
      def initialize(*args)
        @type = 'doc-msword'

        super(*args)
      end
    end
  end
end
