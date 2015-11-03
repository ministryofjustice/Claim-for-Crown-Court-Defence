
class ErrorPresenter

  def initialize(claim, message_file = nil)
    @claim = claim
    @errors = claim.errors
    message_file ||= "#{Rails.root}/config/locales/error_messages.#{I18n.locale}.yml"
    @translations = YAML.load_file(message_file)
    @error_details = ErrorDetailCollection.new
    generate_messages
  end

  def field_level_error_for(fieldname)
    @error_details.short_messages_for(fieldname)
  end

  def header_errors
    @error_details.header_errors
  end

  def size
    @error_details.size
  end

  private

  def generate_messages
    ap "<<<<<<<<<<<<< GENERATE_MESSAGES >>>>>>>>>>>>"
    ap @errors
    @errors.each do |fieldname, error|
      emt = ErrorMessageTranslator.new(@translations, fieldname, error)
      if emt.translation_found?
        long_message = emt.long_message
        short_message = emt.short_message
      else
        long_message = generate_standard_long_message(fieldname, error)
        short_message = generate_standard_short_message(fieldname, error)
      end
      @error_details[fieldname] = ErrorDetail.new(fieldname, long_message, short_message, generate_sequence(fieldname))
    end
  end

  def generate_sequence(fieldname)
    fieldname = fieldname.to_s
    if fieldname =~ /^(\S+)_id$/
      fieldname = $1
    end
    if @translations[fieldname]
      @translations[fieldname]['_seq']
    else
      99999
    end
  end

  def generate_link(fieldname)
    "#" + fieldname
  end

  def generate_standard_long_message(fieldname, error)
    "#{fieldname.to_s.humanize} #{error.humanize.downcase}"
  end

  def generate_standard_short_message(fieldname, error)
    error.humanize
  end

end