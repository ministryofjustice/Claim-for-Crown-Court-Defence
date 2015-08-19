class AdpFormBuilder < ActionView::Helpers::FormBuilder
  def adp_date_fields(attribute)
    day_field_value = @object.send(attribute).strftime('%d') rescue nil
    month_field_value = @object.send(attribute).strftime('%m') rescue nil
    year_field_value = @object.send(attribute).strftime('%Y') rescue nil

    date_fields = AdpDateFields.new(self, @object_name, attribute)
    date_fields.output
  end

  def collection_select2_with_data(method, collection, value_method, text_method, data_options,  options_hash = {}, html_option_hash = {}) 
    result = make_select_start(method)
    result += make_prompt if options_hash[:prompt] == true
    collection.each do |member|
      result += make_option(object.send(method), member, value_method, text_method, data_options)
    end
    result += make_select_end
    result.html_safe
  end


  private

  def make_option(current_value, member, value_method, text_method, data_options)
    value = member.send(value_method)
    option = %Q[<option value="#{member.send(value_method)}"]
    if current_value == member.send(value_method)
      option += %Q[ selected="selected"]
    end
    data_options.each do |data_key, data_method|
      option += %Q[ data-#{data_key}="#{member.send(data_method)}"]
    end
    option += %Q[>#{member.send(text_method)}</option>]
    option
  end


  def make_select_start(method)
    %Q/<select id="#{make_id(method)}" name="#{make_name(method)}" class="select2">/
  end

  def make_select_end
    '</select>'
  end

  def make_id(method)
    "#{make_object_name}_#{method}"
  end

  def make_name(method)
    "#{make_object_name}[#{method}]"
  end

  def make_object_name
    object.class.to_s.downcase
  end


  def make_prompt
    %q[<option value="">Please select</option>]
  end
end


