module Select2Helper
  #
  # a select2 alternative method that can be used
  # on select2 select-lists in place of the capybara
  # select method.
  # e.g. select2 'value-to-select', from: 'select2-list-id'
  #
  def select2(value, options)
    sleep 1 # Allow dropdown to build - we can get flickers without this
    field = page.find("##{options[:from]}", :visible => false)
    page.execute_script("$('##{field[:id]} option').filter(function() { return this.text == '#{value}'; }).attr('selected', true).trigger('change')")
  end
end

World(Select2Helper)
