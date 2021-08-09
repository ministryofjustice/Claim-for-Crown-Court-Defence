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
  class FallbackMessage
    def initialize(key, error)
      @key = parse(key)
      @error = error
    end

    def all
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
      key.association_key
         .gsub('_0_', '_1_')
         .gsub('_attributes', '')
         .split('_')
         .map(&:singularize)
         .join('_')
    end
  end
end
