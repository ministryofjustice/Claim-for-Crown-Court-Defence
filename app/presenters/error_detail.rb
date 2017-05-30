class ErrorDetail
  include Comparable

  attr_reader :attribute, :long_message, :short_message, :api_message

  def initialize(attribute, long_message, short_message, api_message, sequence = 99_999)
    @attribute     = attribute
    @long_message  = long_message
    @short_message = short_message
    @api_message   = api_message
    @sequence      = sequence
  end

  def sequence
    @sequence || 99_999
  end

  def ==(other)
    return false unless other.is_a?(self.class)
    @attribute == other.attribute &&
      @long_message == other.long_message &&
      @short_message == other.short_message &&
      @api_message == other.api_message
  end

  def <=>(other)
    sequence <=> other.sequence
  end

  def long_message_link
    %(<a href="##{@attribute}">#{@long_message}</a>).html_safe
  end
end
