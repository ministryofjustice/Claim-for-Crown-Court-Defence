# frozen_string_literal: true

module GovukComponent
  module PhaseBannerHelpers
    def govuk_phase_banner(phase = nil, body = nil, tag_options = {})
      tag_options = prepend_classes('govuk-phase-banner', tag_options)

      tag.div(**tag_options) do
        tag.p(class: 'govuk-phase-banner__content') do
          concat tag.strong(sanitize(phase), class: 'govuk-tag govuk-phase-banner__content__tag') if phase.present?
          concat tag.span(sanitize(body), class: 'govuk-phase-banner__text')
        end
      end
    end
  end
end
