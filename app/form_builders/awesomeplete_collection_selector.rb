class AwesomepleteCollectionSelector

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
      result += input_tag
      result += ul_start
      result += prompt_line
      collection.each { |item| result += item_line(item) }
      result += ul_end
      result += span_tag
      result += div_end
      result.html_safe
  end


  private

  def input_tag
    %Q|<input class="form-control" id="claim_case_type_id_autocomplete" name="#{@field_name}" #{@value_clause}autocomplete="off" aria-autocomplete="list">|
  end

  def intialize_value_clause
    if @object.send(@method).blank?
      @value_clause = nil
      @display_value = nil
    else
      @display_value = @object.send(method).send(text_method)
      @value_clause = %Q|value="#{@display_value}" |
    end
  end

  def include_blank?
    !@include_blank.nil?
  end

  def prompt?
    !@promt.nil?
  end

  def div_start
    %q|<div class="awesomplete">|
  end

  def div_end
    %q|</div>|
  end

  def ul_start
    %q|<ul>|
  end

  def ul_end
    %q|</ul>|
  end

  def span_tag
    %q|<span class="visually-hidden" role="status" aria-live="assertive" aria-relevant="additions"></span>|
  end

  def prompt_line
    result = nil
    if prompt?
      prompt_selected = @object.blank? ? 'true' : 'false'
      result += %Q|<li aria-selected="#{prompt_selected}">#{@prompt}</li>|
    elsif include_blank?
      prompt_selected = @object.blank? ? 'true' : 'false'
      result += %Q|<li aria-selected="#{prompt_selected}"></li>|
    end
    result
  end

  def item_line(item)
    selected = @display_value == item.send(@text_method) ? 'true' : 'false'
    %Q|<li aria-selected="#{selected}" data-value="#{item.send(@value_method)}">#{item.send(@text_method)}</li>|
  end

end