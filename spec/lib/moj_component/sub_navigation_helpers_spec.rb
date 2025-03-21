RSpec.describe MojComponent::SubNavigationHelpers, type: :helper do
  include RSpecHtmlMatchers

  describe '#moj_subnav' do
    subject(:markup) { helper.moj_subnav(items:, active:) }

    let(:items) do
      {
        information: { href: 'http://example.com', label: 'information_tab_text' }
      }
    end

    let(:active) { :information }

    it { is_expected.to have_tag(:nav, with: { class: 'moj-sub-navigation' }) }
    it { is_expected.to have_tag(:ul, with: { class: 'moj-sub-navigation__list' }) }
    it { is_expected.to have_tag(:li, with: { class: 'moj-sub-navigation__item' }, count: 1) }
    it { is_expected.to have_tag(:a, with: { class: 'moj-sub-navigation__link', 'aria-current': 'page', href: 'http://example.com' }, text: 'information_tab_text') }

    context 'when 3 items' do
      let(:items) do
        {
          information: { href: 'http://example.com/1', label: 'information_tab_text' },
          status: { href: 'http://example.com/2', label: 'status_tab_text' },
          other: { href: 'http://example.com/3', label: 'other_tab_text' }
        }
      end

      it { is_expected.to have_tag(:li, with: { class: 'moj-sub-navigation__item' }, count: 3) }
      it { is_expected.to have_tag(:a, with: { class: 'moj-sub-navigation__link', 'aria-current': 'page', href: 'http://example.com/1' }, text: 'information_tab_text') }
      it { is_expected.to have_tag(:a, with: { class: 'moj-sub-navigation__link', href: 'http://example.com/2' }, text: 'status_tab_text') }

      it do
        is_expected.not_to have_tag(:a, text: 'status_tab_text',
                                        with: { class: 'moj-sub-navigation__link', 'aria-current': 'page' })
      end

      it { is_expected.to have_tag(:a, with: { class: 'moj-sub-navigation__link', href: 'http://example.com/3' }, text: 'other_tab_text') }

      it do
        is_expected.not_to have_tag(:a, text: 'other_tab_txt',
                                        with: { class: 'moj-sub-navigation__link', 'aria-current': 'page' })
      end
    end
  end
end
