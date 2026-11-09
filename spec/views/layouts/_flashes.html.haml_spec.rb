RSpec.describe 'layouts/_flashes' do
  include RSpecHtmlMatchers

  subject(:markup) { render partial: 'layouts/flashes', locals: { flash: messages } }

  let(:messages) { { 'alert' => { title: title_text, text: text } } }
  let(:title_text) { 'Unable to sign in' }
  let(:text) { 'Try again.' }

  it 'renders a labelled MOJ error region with its JavaScript hook' do
    is_expected.to have_tag(:div, with: {
                              class: 'moj-alert moj-alert--error moj-alert--with-heading',
                              role: 'region', 'aria-label': "error: #{title_text}", 'data-module': 'moj-alert'
                            })
  end

  it 'renders the heading' do
    is_expected.to have_tag(:h2, with: { class: 'moj-alert__heading' }, text: title_text)
  end

  it 'renders supporting text as a GOV.UK paragraph' do
    is_expected.to have_tag(:p, with: { class: 'govuk-body' }, text: text)
  end

  it 'does not render a dismiss link' do
    is_expected.not_to have_tag(:a, with: { class: 'moj-alert__dismiss' })
  end

  context 'without supporting text' do
    let(:text) { nil }

    it 'does not render an empty paragraph' do
      is_expected.not_to have_tag(:p)
    end
  end

  context 'with HTML in the message' do
    let(:title_text) { '<script>alert("title")</script>' }
    let(:text) { '<script>alert("text")</script>' }

    it 'escapes the title and supporting text', :aggregate_failures do
      expect(markup).not_to have_tag(:script)
      expect(markup).to have_tag(:h2, text: title_text)
      expect(markup).to have_tag(:p, text: text)
    end
  end

  context 'with a string alert' do
    let(:messages) { { 'alert' => 'Authentication failed.' } }

    it 'keeps the GOV.UK notification banner' do
      is_expected.to have_tag(:div, with: { class: 'govuk-notification-banner' })
    end
  end
end
