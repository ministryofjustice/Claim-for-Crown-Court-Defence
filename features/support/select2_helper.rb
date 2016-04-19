module Select2Helper
  #
  # a select2 alternative method that can be used
  # on select2 select-lists in place of the capybara
  # select method.
  # e.g. select2 'value-to-select', from: 'select2-list-id'
  #
  def select2(value, options)
    select "#{value}", :from => "#{options[:from]}", :visible => false
  end
end

World(Select2Helper)
