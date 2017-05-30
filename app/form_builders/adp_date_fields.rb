class AdpDateFields
  DATE_SEGMENTS = {
    day: '3i',
    month: '2i',
    year: '1i'
  }.freeze

  def initialize(form, object_name, attribute)
    @form = form
    @object = form.object
    @object_name = object_name
    @attribute = attribute
  end

  def output
    day_value = begin
                  @object.send(@attribute).strftime('%d')
                rescue
                  nil
                end
    month_value = begin
                    @object.send(@attribute).strftime('%m')
                  rescue
                    nil
                  end
    year_value = begin
                   @object.send(@attribute).strftime('%Y')
                 rescue
                   nil
                 end

    %(
      #{@form.text_field(@attribute, field_options(day_value, html_id(:day), html_name(:day), 'DD', 2))}
      #{@form.text_field(@attribute, field_options(month_value, html_id(:month), html_name(:month), 'MM', 3))}
      #{@form.text_field(@attribute, field_options(year_value, html_id(:year), html_name(:year), 'YYYY', 4))}
    ).html_safe
  end

  private

  def html_id(date_segment)
    html_name(date_segment).gsub(/\]\[|\[|\]|\(/, '_').gsub(/\_\z/, '').delete(')')
  end

  def html_name(date_segment)
    "#{@object_name}[#{@attribute}(#{DATE_SEGMENTS[date_segment]})]"
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
