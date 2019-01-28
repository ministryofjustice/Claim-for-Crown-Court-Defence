class CommonAutocomplete < SitePrism::Section
  element :auto_input, '.autocomplete__input'
  sections :menu_items, '.autocomplete__menu > li' do end

  def choose_autocomplete_option(name)
    auto_input.set(name)
    wait_for_ajax
    options = menu_items.select { |option| option.text.eql?(name) }
    choice = options.first
    root = choice.root_element
    root.click
  end
end
