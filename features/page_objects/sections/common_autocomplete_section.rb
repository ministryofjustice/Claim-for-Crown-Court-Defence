class CommonAutocomplete < SitePrism::Section
  element :auto_input, '.autocomplete__input'
  sections :menu_items, '.autocomplete__menu > li' do end

  def choose_autocomplete_option(name)
    3.times do |i|
      auto_input.set(name)
      break unless menu_items.first.text == 'No results found'
    end
    options = menu_items.select { |option| option.text.eql?(name) }
    choice = options.first
    root = choice.root_element
    root.click
  end
end
