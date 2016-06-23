
# class to create specialized text field wrapped in all the GDS gubbins
class AdpTextField

  include ExternalUsers::ClaimsHelper
  include ActionView::Helpers::TagHelper


  # instantiate an AdpTextField object
  # * form: the instance of AdpFormBuilder that this is called from
  # * method: the method on the object that the form is wrapping that this input field is for
  # * options:
  #   * label: label to be provided for the input field
  #   * hint_text: Hint text displayed underneath the label
  #   * input_classes: Css classes on the input
  #   * input_type: Input type will default to `text`
  #   * errors: An ErrorPresenter for the form object, or the form object itself

  def initialize(form, method, options)
    @form = form
    @method = method
    @options = options
    @form_field_id = generate_form_field_id
    @form_field_name = generate_form_field_name
    @errors = options[:errors]
    @input_classes = options[:input_classes] || ''
    @input_type = options[:input_type] || 'text'
    @input_type_string = @input_type;
    @input_is_number = false

    if @input_type == 'currency'
      @input_is_currency = true
    end

    if @input_type == 'currency' || @input_type =='number'
      @input_type_string = 'number'
      @input_is_number = true
      @input_min = options[:input_min] || '0'
      @input_max = options[:input_max] || '99999'
    end

    @anchor_id = generate_anchor_id
  end


  # the methods output_buffer= and output_buffer are required by the content_tag
  # methods, called from the validation_error_message in ExternalUsers::ClaimsHelper
  #
  def output_buffer=(value)
    @errors = value
  end

  def output_buffer
    @errors
  end

  def has_errors?
    return false if @errors.nil?
    @errors.errors_for?(@anchor_id.to_sym)
  end

  def to_html
    result = div_start
    result += anchor
    result += label
    result += hint
    result += label_close
    result += input_field
    result += error_message
    result += div_close
    result.html_safe
  end

  private

  def generate_form_field_id
    # @form.object_name either returns a symbol for top level fields (e.g. :claim), or
    # a string like "claim[defendants_attributes][0]" for cocoon nested objects
    if @form.object_name.is_a?(Symbol)
      "#{@form.object_name}_#{@method}"
    else
      # translates e.g. claim[defendants_attributes][0]_last_name to claim_defendants_attributes_0_last_name
      @form.object_name.to_s.gsub(/\[/, '_').gsub(/\]/, '_').gsub('__', '_') + "#{@method}"
    end
  end

  def generate_form_field_name
    # @form.object_name either returns a symbol for top level fields (e.g. :claim), or
    # a string like "claim[defendants_attributes][0]" for cocoon nested objects
    "#{@form.object_name}[#{@method}]"
  end

  def generate_anchor_id
    # translates e.g. claim_defendants_attributes_0_last_name to defendant_1_last_name
    anchor = @form_field_id.sub(/^claim_/, '').gsub('s_attributes', '')
    parts = anchor.split('_')
    incremented_anchor_parts = []
    parts.each do |part|
      if part =~ /^[0-9]{1,2}$/
        incremented_anchor_parts << (part.to_i + 1).to_s
      else
        incremented_anchor_parts << part
      end
    end
    incremented_anchor_parts.join('_')
  end

  def div_start
    result = %Q|<div class="form-group #{@method}_wrapper|
    result += %Q| field_with_errors| if has_errors?
    result += %Q|">|
    result
  end

  def anchor
    %Q|<a id="#{@anchor_id}"></a>|
  end

  def currency
    %Q|<span class="currency-indicator">&pound;</span>|
  end

  def label
    %Q|<label class="form-label" for="#{@form_field_id}">#{@options[:label]}|
  end

  def label_close
    %Q|</label>|
  end

  def error_message
    has_errors? ? validation_error_message(@errors, @anchor_id) : ''
  end

  def hint
    if @options[:hint_text]
      %Q|<span class="form-hint">#{@options[:hint_text]}</span>|
    else
      ''
    end
  end

  def input_field
    result = %Q||
    if @input_is_currency
      result += %Q|<span class="currency-indicator">&pound;</span>|
    end
    result += %Q|<input class="form-control #{@input_classes}" type="#{@input_type_string}" name="#{@form_field_name}" id="#{@form_field_id}" |
    result += %Q|value="#{@form.object.__send__(@method)}" | unless @form.object.__send__(@method).nil?
    if @input_is_number
      result += %Q|min="#{@input_min}" |
      result += %Q|max="#{@input_max}" |
    end
    result += %Q|/>|
    result
  end

  def div_close
    '</div>'
  end
end




