module MojComponent
  module SubNavigationHelpers
    def moj_subnav(tag_options: {}, items: {}, active: nil)
      tag_options[:class] = 'moj-sub-navigation'
      tag.nav(**tag_options) do
        tag.ul(class: 'moj-sub-navigation__list') do
          items.each do |key, value|
            concat moj_subnav_item(active: key == active, **value)
          end
        end
      end
    end

    def moj_subnav_item(label:, href:, active:)
      tag.li(
        link_to(label, href, class: 'moj-sub-navigation__link', aria: { current: active ? 'page' : nil }),
        class: 'moj-sub-navigation__item'
      )
    end
  end
end
