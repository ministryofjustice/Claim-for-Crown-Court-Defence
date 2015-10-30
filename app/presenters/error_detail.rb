 
class ErrorDetail

  attr_reader :attribute, :long_message, :short_message
  
  def initialize(attribute, long_message, short_message)
    @attribute     = attribute
    @long_message  = long_message
    @short_message = short_message
  end


  def ==(other)
    return false unless other.is_a?(self.class)
    @attribute == other.attribute && 
    @long_message == other.long_message && 
    @short_message == other.short_message
  end


  def long_message_link
    %Q[<a href="##{@attribute.to_s}">#{@long_message}</a>].html_safe
  end
end