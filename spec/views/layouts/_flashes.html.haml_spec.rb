RSpec.describe 'layouts/_flashes' do
  include RSpecHtmlMatchers

  subject(:markup) { render partial: 'layouts/flashes', locals: { flash: messages } }

  let(:messages) { { 'alert' => text } }
  let(:text) { 'Try again.' }

  context 'with HTML in the message' do
    let(:text) { '<script>alert("text")</script>' }

    it 'escapes the message', :aggregate_failures do
      expect(markup).not_to have_tag(:script)
      expect(markup).to have_tag(:p, text: text)
    end
  end

  context 'with an error summary' do
    let(:messages) { { 'error_summary' => text } }

    context 'with HTML in the message' do
      let(:text) { '<script>alert("text")</script>' }

      it 'escapes the message', :aggregate_failures do
        expect(markup).not_to have_tag(:script)
        expect(markup).to have_tag(:p, text: text)
      end
    end
  end
end
