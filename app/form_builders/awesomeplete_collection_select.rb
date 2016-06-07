class AwesomepleteCollectionSelect

  def initialize(form_object, method, collection, value_method, text_method, data_options)
    @form_object = form_object
    @object = form_object.send(method)
    @method = method
    @collection = collection
    @value_method = value_method
    @text_method = text_method
    @data_options = data_options
    raise ArgumentError.new "Must specify name of field in data options" unless data_options.key?(:name)
    @field_name = data_options[:name]
    @include_blank = data_options[:include_blank]
    @prompt = data_options[:prompt]
    initialize_value_clause
  end

  def to_html
      result = div_start
      # result = %Q|<div class="awesomplete">|
      if object.send(method).blank?
        value_clause = nil
        display_value = nil
      else
        display_value = object.send(method).send(text_method)
        value_clause = %Q|value="#{display_value}" |
      end
      result += %Q|<input class="form-control" id="claim_case_type_id_autocomplete" name="#{options[:name]}" #{value_clause}autocomplete="off" aria-autocomplete="list">|
      result += %Q|<ul>|
      if data_options[:prompt]
        prompt_selected = object.send(method).blank? ? 'true' : 'false'
        result += %Q|<li aria-selected="#{prompt_selected}">#{data_options[:prompt]}</li>|
      elsif data_options[:include_blank]
        prompt_selected = object.send(method).blank? ? 'true' : 'false'
        result += %Q|<li aria-selected="#{prompt_selected}"></li>|
      end
      collection.each do |item|
        selected = display_value == item.send(text_method) ? 'true' : 'false'
        result += %Q|<li aria-selected="#{selected}" data-value="#{item.send(value_method)}">#{item.send(text_method)}</li>|
      end
      result += %Q|</ul>|
      result += %Q|<span class="visually-hidden" role="status" aria-live="assertive" aria-relevant="additions"></span>|
      # result += %Q|</div>|
      result += div_end
      result.html_safe
  end


  private

  def intialize_value_clause
    if @object.send(@method)
  end

  def include_blank?
    !@include_blank.nil?
  end

  def prompt?
    !@promt.nil?
  end

  def div_start
    %Q|<div class="awesomplete">|
  end

  def div_end
    %Q|</div>|
  end


end