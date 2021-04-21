# frozen_string_literal: true

RSpec.describe GovukComponent::NotificationBannerHelpers, type: :helper do
  include RSpecHtmlMatchers

  describe '#govuk_notification_banner' do
    subject(:markup) { helper.govuk_notification_banner('Notice', 'This is a notification banner') }

    it 'adds notification banner' do
      expect(markup).to have_tag(:div, with: { class: 'govuk-notification-banner' })
    end

    it 'adds notification banner with an aria-labelledby attributes' do
      expect(markup).to have_tag(:div, with: { 'aria-labelledby': 'govuk-notification-banner-title' })
    end

    it 'adds notification banner with a data-module attribute' do
      expect(markup).to have_tag(:div, with: { 'data-module': 'govuk-notification-banner' })
    end

    it 'adds notification banner with a role attribute' do
      expect(markup).to have_tag(:div, with: { role: 'alert' })
    end

    it 'adds nested banner header' do
      expect(markup).to have_tag(:div, with: { class: 'govuk-notification-banner' }) do
        with_tag(:div, with: { class: 'govuk-notification-banner__header' })
      end
    end

    # rubocop:disable RSpec/ExampleLength
    it 'adds nested heading in banner header' do
      expect(markup).to have_tag(:div, with: { class: 'govuk-notification-banner' }) do
        with_tag(:div, with: { class: 'govuk-notification-banner__header' }) do
          with_tag(:h2, text: 'Notice',
                        with: { class: 'govuk-notification-banner__title', id: 'govuk-notification-banner-title' })
        end
      end
    end
    # rubocop:enable RSpec/ExampleLength

    it 'adds nested banner content' do
      expect(markup).to have_tag(:div, with: { class: 'govuk-notification-banner' }) do
        with_tag(:div, with: { class: 'govuk-notification-banner__content' })
      end
    end

    it 'adds nested element in banner content' do
      expect(markup).to have_tag(:div, with: { class: 'govuk-notification-banner' }) do
        with_tag(:div, with: { class: 'govuk-notification-banner__content' }) do
          with_tag(:p, text: 'This is a notification banner', with: { class: 'govuk-notification-banner__heading' })
        end
      end
    end

    context 'with custom html options' do
      subject(:markup) do
        helper.govuk_notification_banner('Notice', 'This is a notification banner',
                                         class: 'my-custom-class1 my-custom-class2')
      end

      it 'adds notification banner with custom classes' do
        expect(markup).to have_tag(:div,
                                   with: { class: 'govuk-notification-banner my-custom-class1 my-custom-class2' })
      end
    end

    context 'with capture block' do
      subject(:markup) do
        helper.govuk_notification_banner('Notice') do
          'This is a notification banner'
        end
      end

      # rubocop:disable RSpec/ExampleLength
      it 'adds nested heading in banner header' do
        expect(markup).to have_tag(:div, with: { class: 'govuk-notification-banner' }) do
          with_tag(:div, with: { class: 'govuk-notification-banner__header' }) do
            with_tag(:h2, text: 'Notice',
                          with: { class: 'govuk-notification-banner__title', id: 'govuk-notification-banner-title' })
          end
        end
      end
      # rubocop:enable RSpec/ExampleLength

      it 'adds nested element in banner content' do
        expect(markup).to have_tag(:div, with: { class: 'govuk-notification-banner' }) do
          with_tag(:div, text: 'This is a notification banner', with: { class: 'govuk-notification-banner__content' })
        end
      end
    end
  end
end
