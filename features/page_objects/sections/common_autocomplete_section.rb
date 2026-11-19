class CommonAutocomplete < SitePrism::Section
  element :auto_input, '.autocomplete__input'

  def choose_autocomplete_option(name)
    auto_input.set(name)
    find('.autocomplete__menu > li', exact_text: name).click
  end
end
