class AdpFormBuilder < ActionView::Helpers::FormBuilder
  include ActionView::Helpers::FormTagHelper

  def collection_select2_with_data(method, collection, value_method, text_method, data_options, options_hash = {}, html_option_hash = {})
    result = make_select_start(method)
    result += make_prompt if options_hash[:prompt] == true
    collection.each do |member|
      result += make_option(object.send(method), member, value_method, text_method, data_options)
    end
    result += make_select_end
    result.html_safe
  end


  def anchored_label(label, anchor_name = nil, options = {})
    anchor_name ||= label.gsub(' ', '_').downcase
    anchor_and_label_markup(anchor_name, label, options)
  end

  def anchored_without_label(label, anchor_name = nil, options = {})
    anchor_name ||= label.gsub(' ', '_').downcase
    anchor_and_label_markup(anchor_name, nil, options)
  end

  def anchored_attribute(attribute, options = {})
    resource = object.class.name.demodulize.underscore
    anchor_name = [resource, attribute.gsub(' ', '_')].join('.').downcase
    anchor_and_label_markup(anchor_name, nil, options)
  end


  private

  def anchor_and_label_markup(anchor_name, label, options = {})
    anchor_html = content_tag(:a, nil, { name: anchor_name }.merge(options[:anchor_attributes] || {}))
    label_html  = nil

    if label
      label_for  = full_anchor_name_for(object, anchor_name)
      label_html = label_tag(label_for, label, options[:label_attributes])
    end

    [anchor_html, label_html].join.html_safe
  end

  def full_anchor_name_for(object, anchor_name)
    "#{make_object_name}_#{anchor_name}"
  end

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
    klass_name = object.class.to_s
    klass_name = 'Claim' if klass_name =~ /^Claim::/
    klass_name.camelize.downcase
  end


  def make_prompt
    %q[<option value="">Please select</option>]
  end
end
