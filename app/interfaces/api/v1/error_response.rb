# #############################################################
# ErrorResponse Class: Retrieves validation error messages from
# translations file(s) and responds to erroneous API endpoint
# request with those error messages.
#
# error translations are divided into submodels:
# - Claim errors have no submodel.
# - Fee error translations are broken down into
#   the three different types plus a fallback type
#   ,in case the type is unknown.
# - Any other claim submodel should use its model
#   name in snake case.
#
# NOTE: for API we "spoof" the submodel count/number/instance
#       as 1
# #############################################################

class ErrorResponse

  attr :body
  attr :status

  VALID_MODEL_KLASSES = [Fee, Expense, Claim::BaseClaim, Defendant, DateAttended, RepresentationOrder]

  def initialize(object)
    @error_messages = []
    @translations = translations
    if VALID_MODEL_KLASSES.include? object.class
      @model = object
      build_error_response
    else
      @status = object.try(:message) == 'Unauthorised' ? 401 : 400
      @body = error_messages.push({ error: object.try(:message).nil? ? "No message provided by object #{object.class.name}" : object.message })
    end
  end

private

  def error_messages
    @error_messages
  end

  def translations
    message_file ||= Rails.root.join('config','locales',"error_messages.#{I18n.locale}.yml")
    YAML.load_file(message_file)
  end

   def fallback_api_message(field_name, error)
    "#{field_name.to_s.humanize} #{error.humanize.downcase}"
  end

  def submodel_prefix
    submodel_instance_num = ''
    m = @model

    if m.is_a?(Fee)
      case
        when m.is_basic?
          submodel ='basic_fee'
        when m.is_misc?
          submodel ='misc_fee'
        when m.is_fixed?
          submodel ='fixed_fee'
        else
          submodel = 'fee' # no fee type may have been specified
      end
      submodel_instance_num = "#{submodel}_1_"
    elsif !m.try(:claim).nil?
      submodel_instance_num = "#{m.class.name.underscore}_1_"
    end

    submodel_instance_num
  end

  # format of field name determines lookup in translations
  def format_field_name(field_name)
    "#{submodel_prefix + field_name.to_s}".to_sym
  end

  def fetch_and_translate_error_messages
    @model.errors.each do |field_name, error|
      field_name = format_field_name(field_name)
      emt = ErrorMessageTranslator.new(@translations, field_name, error)
      if emt.translation_found?
        error_messages.push({ error: emt.api_message })
      else
        error_messages.push({ error: fallback_api_message(field_name, error) })
      end
    end
  end

  def build_error_response
    unless @model.errors.empty?
      fetch_and_translate_error_messages
      @body = error_messages
      @status = 400
    else
       raise "unable to build error response as no errors were found"
     end
  end
end
