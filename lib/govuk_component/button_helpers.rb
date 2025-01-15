# frozen_string_literal: true

module GovukComponent
  module ButtonHelpers
    GOVUK_BUTTON_START_SVG_OPTIONS = {
      class: 'govuk-button__start-icon',
      xmlns: 'http://www.w3.org/2000/svg',
      height: '19',
      width: '17.5',
      viewBox: '0 0 33 40',
      'aria-hidden': 'true',
      focusable: 'false'
    }.freeze

    GOVUK_BUTTON_START_SVG_PATH_OPTIONS = {
      fill: 'currentColor',
      d: 'M0 0h13l20 20-20 20H0l20-20z'
    }.freeze

    def govuk_button(content = nil, tag_options = {}, &block)
      tag_options = prepend_classes('govuk-button', tag_options)
      tag_options[:data] = { module: 'govuk-button', 'prevent-double-click': 'true' }
      disable_if(tag_options)

      if block
        tag.button(tag_options, &block)
      else
        tag.button(content, **tag_options)
      end
    end

    def govuk_button_secondary(content = nil, tag_options = {}, &)
      tag_options = prepend_classes('govuk-button--secondary', tag_options)

      govuk_button(content, tag_options, &)
    end

    def govuk_button_warning(content = nil, tag_options = {}, &)
      tag_options = prepend_classes('govuk-button--warning', tag_options)

      govuk_button(content, tag_options, &)
    end

    # Following the Rails link_to helper
    # `https://api.rubyonrails.org/v6.0.3/classes/ActionView/Helpers/UrlHelper.html#method-i-link_to`
    def govuk_button_start(name = nil, options = nil, tag_options = {}, &block)
      options = name if block
      url = url_for(options)
      tag_options[:href] ||= url
      tag_options = prepend_classes('govuk-button--start', tag_options)
      govuk_link_button_options(tag_options)
      content = block ? capture(&block) : name || url

      tag.a(**tag_options) do
        concat content
        concat govuk_button_start_svg
      end
    end

    def govuk_link_button(name = nil, options = nil, tag_options = {}, &block)
      options = name if block
      url = url_for(options)
      tag_options[:href] ||= url
      govuk_link_button_options(tag_options)
      disable_if(tag_options)
      content = block ? capture(&block) : name || url

      tag.a(content, **tag_options, &block)
    end

    def govuk_link_button_secondary(name = nil, options = nil, tag_options = {}, &)
      tag_options = prepend_classes('govuk-button--secondary', tag_options)

      govuk_link_button(name, options, tag_options, &)
    end

    def govuk_link_button_warning(name = nil, options = nil, tag_options = {}, &)
      tag_options = prepend_classes('govuk-button--warning', tag_options)

      govuk_link_button(name, options, tag_options, &)
    end

    private

    def disable_if(options)
      return unless options[:disabled].present? && options[:disabled].to_s == 'true'
      options[:aria] = { disabled: 'true' }
    end

    def govuk_link_button_options(options)
      options[:data] = { module: 'govuk-button' }
      options[:draggable] = 'false'
      options[:role] = 'button'
      prepend_classes('govuk-button', options)
    end

    def govuk_button_start_svg
      svg_path = tag.path(**GOVUK_BUTTON_START_SVG_PATH_OPTIONS)
      tag.svg(svg_path, **GOVUK_BUTTON_START_SVG_OPTIONS)
    end
  end
end
