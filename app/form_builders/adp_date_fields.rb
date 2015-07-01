class AdpDateFields
  DATE_SEGMENTS = {
    day: '3i',
    month: '2i',
    year: '1i'
  }

  def initialize(form, object, attribute)
    @form = form
    @object = object
    @attribute = attribute
  end

  def output
    day_value = @object.send(@attribute).strftime('%d') rescue nil
    month_value = @object.send(@attribute).strftime('%m') rescue nil
    year_value = @object.send(@attribute).strftime('%Y') rescue nil

    %Q[
      #{@form.text_field(@attribute, field_options(day_value, html_id(:day), html_name(:day), 'DD', 2))}
      #{@form.text_field(@attribute, field_options(month_value, html_id(:month), html_name(:month), 'MM', 3))}
      #{@form.text_field(@attribute, field_options(year_value, html_id(:year), html_name(:year), 'YYYY', 4))}
    ].html_safe
  end

  private

  def html_id(date_segment)
    "#{object_name}_#{@attribute}_#{DATE_SEGMENTS[date_segment]}"
  end

  def html_name(date_segment)
    "#{object_name}[#{@attribute}(#{DATE_SEGMENTS[date_segment]})]"
  end

  def object_name
    @object.class.to_s.underscore
  end

  def field_options(value, id, name, placeholder, size)
    {
      value: value,
      id: id,
      name: name,
      placeholder: placeholder,
      size: size
    }
  end
end
