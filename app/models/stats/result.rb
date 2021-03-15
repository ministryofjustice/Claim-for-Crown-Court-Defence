module Stats
  class Result
    attr_reader :content, :format

    def initialize(content, format)
      @content = content
      @format = format
    end

    def content_type
      @content_type ||= {
        csv: 'text/csv',
        json: 'application/json'
      }[format.to_sym]
    end

    def io
      @io ||= StringIO.new(content)
    end
  end
end
