RSpec.describe FeedbackBannerHelper do
  include RSpecHtmlMatchers

  describe '#feedback_banner' do
    subject(:markup) { helper.feedback_banner('This is a new service') }

    it 'adds feedback_banner with govuk class' do
      is_expected.to have_tag(:div, with: { class: 'feedback-banner' })
    end

    it 'adds nested p tag with govuk class' do
      is_expected.to have_tag(:div) do
        with_tag(:p, with: { class: 'feedback-banner__content' })
      end
    end

    it 'adds nested span in p tag with govuk class' do
      is_expected.to have_tag(:div) do
        with_tag(:p) do
          with_tag(:span, with: { class: 'feedback-banner__text' })
        end
      end
    end

    it 'adds banner__text to nested span' do
      is_expected.to have_tag(:div) do
        with_tag(:p) do
          with_tag(:span, text: 'This is a new service')
        end
      end
    end
  end
end
