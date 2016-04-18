module Select2Helper
  #
  # a select2 alternative method that can be used
  # on select2 select-lists in place of the capybara
  # select method.
  # e.g. select2 'value-to-select', from: 'select2-list-id'
  #
  def select2(value, options)
    sleep 2 # Allow dropdown to build - we can get flickers without this
    # page.find("##{options[:from]}").set(value)
    # page.find("##{options[:from]}", :visible => false).set('#{value}')
    select('#{value}', :from => page.find("##{options[:from]}", :visible => false))

    script = "$('#{options[:from]}').trigger('change');"
    page.execute_script(script);

    sleep 2

    # downcase_value = value.downcase

    # page.all("##{options[:from]}_autocomplete + ul li").each do |e|
    #   if e.text.downcase == downcase_value
    #     e.click
    #     return
    #   end
    # end

    # raise "Value not found in select list: #{value}"
  end
end

World(Select2Helper)
