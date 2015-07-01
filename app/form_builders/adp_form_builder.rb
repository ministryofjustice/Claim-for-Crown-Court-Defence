class AdpFormBuilder < ActionView::Helpers::FormBuilder
  def adp_date_fields(attribute)
    day_field_value = @object.send(attribute).strftime('%d') rescue nil
    month_field_value = @object.send(attribute).strftime('%m') rescue nil
    year_field_value = @object.send(attribute).strftime('%Y') rescue nil

    date_fields = AdpDateFields.new(self, @object, attribute)
    date_fields.output
    #
    # day_field_options = {
    #   value: day_field_value,
    #   id: "#{@object_name}_#{attribute}_3i",
    #   name: "#{@object_name}[#{attribute}(3i)]",
    #   placeholder: 'DD',
    #   size: 2
    # }
    #
    # month_field_options = {
    #   value: month_field_value,
    #   id: "#{@object_name}_#{attribute}_2i",
    #   name: "#{@object_name}[#{attribute}(2i)]",
    #   placeholder: 'MM',
    #   size: 3
    # }
    #
    # year_field_options = {
    #   value: year_field_value,
    #   id: "#{@object_name}_#{attribute}_1i",
    #   name: "#{@object_name}[#{attribute}(1i)]",
    #   placeholder: 'YYYY',
    #   size: 4
    # }
    #
    # html = %Q[
    #  #{text_field(attribute, day_field_options)}
    #  #{text_field(attribute, month_field_options)}
    #  #{text_field(attribute, year_field_options)}
    # ].html_safe
  end
end
