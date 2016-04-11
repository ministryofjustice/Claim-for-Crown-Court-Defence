module Select2Helper

  #
  # a select2 alternative method that can be used
  # on select2 select-lists in place of the capybara
  # select method.
  # e.g. select2 'value-to-select', from: 'select2-list-id'
  #
  def select2(value, options)
    page.find("#s2id_#{options[:from]} a").click
    page.all("ul.select2-results li").each do |e|
      if e.text == value
        e.click
        return
      end
    end
  end

end

World(Select2Helper)
