module Select2Helper

  #
  # a select2 alternative method that can be used
  # on select2 select-lists in place of the capybara
  # select method.
  # e.g. select2 'value-to-select', from: 'select2-list-id'
  #
  def select2(value, attrs)
    first("#s2id_#{attrs[:from]}").click
    find(".select2-input").set(value)
    within ".select2-result" do
      find("span", text: value).click
    end
  end

end

World(Select2Helper)