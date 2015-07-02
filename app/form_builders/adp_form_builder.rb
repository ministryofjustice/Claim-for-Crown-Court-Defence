class AdpFormBuilder < ActionView::Helpers::FormBuilder
  def adp_date_fields(attribute)
    day_field_value = @object.send(attribute).strftime('%d') rescue nil
    month_field_value = @object.send(attribute).strftime('%m') rescue nil
    year_field_value = @object.send(attribute).strftime('%Y') rescue nil

    date_fields = AdpDateFields.new(self, @object_name, attribute)
    date_fields.output
  end
end
