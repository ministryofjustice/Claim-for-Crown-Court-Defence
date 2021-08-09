#
# class to generate default fallback
# error messages for missing translations
#
# Note that this does not handle error keys
# of format `foo.bar.baz` as it expects an
# instance of ErrorMessage::Key, which already
# converts this format to `foo_0_bar_0_baz`
#
module ErrorMessage
  class Fallback
    def initialize(key, error)
      @key = parse(key)
      @error = error
    end

    def messages
      [long, short, api]
    end

    def long
      "#{@key.humanize} #{@error.humanize.downcase}"
    end

    def short
      @error.humanize
    end

    def api
      long
    end

    private

    def parse(key)
      key.to_s
         .gsub('_attributes', '')
         .split('_')
         .map(&:singularize)
         .join('_')
    end
  end
end
