module GovUkDateFields
  class FormFields
    def output
      day_value = @object.send("#{@attribute}_dd")
      month_value = @object.send("#{@attribute}_mm")
      year_value = @object.send("#{@attribute}_yyyy")

      %Q[
        #{@form.text_field(@attribute, field_options(day_value, html_id(:day), html_name(:day), '', 2))}
        #{@form.text_field(@attribute, field_options(month_value, html_id(:month), html_name(:month), '', 3))}
        #{@form.text_field(@attribute, field_options(year_value, html_id(:year), html_name(:year), '', 4))}
      ].html_safe
    end
  end
end
