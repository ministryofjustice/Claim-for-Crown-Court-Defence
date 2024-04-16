class AdpFormBuilder < ActionView::Helpers::FormBuilder
  include ActionView::Helpers::FormTagHelper

  def anchored_label(label, anchor_name = nil, options = {})
    anchor_name ||= label.tr(' ', '_').downcase
    anchor_and_label_markup(anchor_name, label, options)
  end

  def anchored_without_label(label, anchor_name = nil, options = {})
    anchor_name ||= label.tr(' ', '_').downcase
    anchor_and_label_markup(anchor_name, nil, options)
  end

  # Use this helper to generate the correct anchor for has_one attributes,
  # do not use it for attributes in the object being rendered.
  #
  def anchored_attribute(attribute, options = {})
    resource = object.class.name.demodulize.underscore
    anchor_name = [resource, attribute.tr(' ', '_')].join('.').downcase
    anchor_and_label_markup(anchor_name, nil, options)
  end

  private

  def anchor_and_label_markup(anchor_name, label, options = {})
    anchor_attributes = { id: anchor_name }.merge(options[:anchor_attributes] || {})
    anchor_html = tag.a(nil, **anchor_attributes)
    label_html = nil

    if label
      label_for = full_anchor_name_for(object, anchor_name)
      label_html = label_tag(label_for, label, options[:label_attributes])
    end

    [anchor_html, label_html].join.html_safe
  end

  def full_anchor_name_for(_object, anchor_name)
    "#{make_object_name}_#{anchor_name}"
  end

  def make_object_name
    klass_name = object.class.to_s
    klass_name = 'Claim' if klass_name.start_with?('Claim::')
    klass_name.camelize.downcase
  end
end
