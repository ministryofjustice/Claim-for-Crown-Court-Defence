# frozen_string_literal: true

module GovukComponent
  module LinkHelpers
    def govuk_back_link_to(body = nil, url = nil, tag_options = {})
      tag_options = prepend_classes('govuk-back-link', tag_options)
      link_to body, url, **tag_options
    end

    def govuk_footer_link_to(body = nil, url = nil, tag_options = {})
      tag_options = prepend_classes('govuk-footer__link', tag_options)
      link_to body, url, **tag_options
    end

    def govuk_header_link_to(body = nil, url = nil, tag_options = {})
      tag_options = prepend_classes('govuk-header__link', tag_options)
      link_to body, url, **tag_options
    end

    def govuk_link_to(body = nil, url = nil, tag_options = {})
      tag_options = prepend_classes('govuk-link', tag_options)
      link_to body, url, **tag_options
    end

    def govuk_mail_to(body = nil, url = nil, tag_options = {})
      tag_options = prepend_classes('govuk-link', tag_options)
      mail_to body, url, **tag_options
    end

    def govuk_skip_link_to(body = nil, url = nil, tag_options = {})
      tag_options = prepend_classes('govuk-skip-link', tag_options)
      tag_options[:data] = { module: 'govuk-skip-link' }
      link_to body, url, **tag_options
    end
  end
end
