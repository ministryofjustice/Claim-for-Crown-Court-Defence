module FeedbackBannerHelper
  def feedback_banner(body = nil)
    tag.div(class: 'feedback-banner') do
      tag.p(class: 'feedback-banner__content') do
        concat tag.span(sanitize(body), class: 'feedback-banner__text')
      end
    end
  end
end
