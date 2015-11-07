class ErrorResponse

  attr :body
  attr :status

  VALID_MODEL_KLASSES = [Fee, Expense, Claim, Defendant, DateAttended, RepresentationOrder]

  def initialize(object)
    @error_messages = []
    @translations = translations
    if VALID_MODEL_KLASSES.include? object.class
      @model = object
      build_error_response
    else
      @body = error_messages.push({ error: object.message })
      @status = object.message == 'Unauthorised' ? 401 : 400
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

  #
  # error translations are divided into submodels.
  # - Claim errors have no submodel.
  # - Fee error translations are broken down into
  #   the three different types plus a fallback type
  #   ,in case the type is unknown.
  # - Any other claim submodel should use its name.
  # NOTE: for API we "spoof" the submodel count/number/instance as 1
  def submodel_prefix
    submodel_prefix = ''

    if @model.is_a?(Fee)
      if @model.is_basic?
        submodel  ='basic_fee'
      elsif @model.is_misc?
        submodel  ='misc_fee'
      elsif @model.is_fixed?
        submodel  ='fixed_fee'
      else
        submodel = 'fee' # no fee type may have been specified
      end
      submodel_prefix = "#{submodel}_1_"
    elsif !@model.try(:claim).nil?
      submodel_prefix = "#{@model.class.name.downcase}_1_"
    end

    submodel_prefix
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
