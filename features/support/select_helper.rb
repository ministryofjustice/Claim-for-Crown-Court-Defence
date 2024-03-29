module SelectHelper
  #
  # https://github.com/jnicklas/capybara/blob/6a4676a62e09a569c58edd6c630764c8e3624276/lib/capybara/node/actions.rb#L208
  #
  def select(value, options)
    if options.delete(:autocomplete) == false
      super value.to_s, visible: false, **options
    else
      fill_autocomplete(options[:from], with: value.to_s)
    end
  end

  # http://ruby-journal.com/how-to-do-jqueryui-autocomplete-with-capybara-2/
  # It requires jQuery to parse XPath, making use of a plugin: https://github.com/ilinsky/jquery-xpath
  #
  def fill_autocomplete(field, options = {})
    dropdown = find(:select, field, visible: false)
    container = dropdown.find(:xpath, '..')
    input_field = container.find('input.tt-input')
    input_field.set options[:with]

    page.execute_script %Q{ $(document.body).xpath('#{input_field.path}').trigger('focus') }
    page.execute_script %Q{ $(document.body).xpath('#{input_field.path}').trigger('keydown') }

    selector = %Q{.tt-menu .tt-suggestion:contains("#{options[:with]}")}
    filter = %Q{function() { return $(this).text() === "#{options[:with]}" }} # needed to rule out multiple matches

    page.execute_script %Q{ $('#{selector}').filter(#{filter}).trigger('mouseenter').trigger('click') }
  end
end

World(SelectHelper)
