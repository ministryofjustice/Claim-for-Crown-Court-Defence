class ClaimShowPage < BasePage
  section :nav, "nav.govuk-service-navigation__wrapper > ul" do
    element :your_claims, "li:nth-of-type(1) > a"
    element :archive, "li:nth-of-type(2) > a"
  end

  element :status, "div.claim-hgroup strong.govuk-tag"
  element :edit_this_claim, "div.claim-detail-actions a:nth-of-type(1)"
  element :fees, "#claim-assessment-attributes-fees-field"
  element :expenses, "#claim-assessment-attributes-expenses-field"
  element :authorised, "label[for='claim-state-authorised-field']"
  element :update, "button#button.govuk-button"
  element :refused, "label[for='claim-state-refused-field']"
  element :rejected, "label[for='claim-state-rejected-field']"

  sections :rejection_reasons, '.js-cw-claim-rejection-reasons .multiple-choice' do
    element :label, 'label'
    element :input, 'input'
  end
  element :reject_reason_text, '#claim-reject-reason-text-field'

  sections :refusal_reasons, '.js-cw-claim-refuse-reasons .multiple-choice' do
    element :label, 'label'
    element :input, 'input'
  end
  element :refuse_reason_text, '#claim-refuse-reason-text-field'

  section :messages_panel, "#claim-accordion .messages-container" do
    element :enter_your_message, "textarea#message-body-field"
    element :send, 'button.govuk-button', text: 'Send'

    def upload_file(path)
      attach_file("attachments", path)
    end

    sections :messages, '.message-body' do
    end
  end
end
