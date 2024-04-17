class GdsAdpFormBuilder < ActionView::Helpers::FormBuilder
  delegate :content_tag, :tag, :safe_join, :link_to, :capture, to: :@template

  include ActionView::Helpers::FormTagHelper
  include ActionView::Context
  include GOVUKDesignSystemFormBuilder::Builder
end
