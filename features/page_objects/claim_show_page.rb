class ClaimShowPage < SitePrism::Page
  section :nav, "div.breadcrumbs > ol" do
    element :your_claims, "li:nth-of-type(1) > a"
    element :archive, "li:nth-of-type(2) > a"
  end

  element :status, "div.claim-hgroup div.claim-status > span.state"
  element :messages_tab, "#claim-accordion button:nth-of-type(1)"
  element :edit_this_claim, "div.claim-detail-actions a:nth-of-type(1)"
  element :fees, "#claim_assessment_attributes_fees"
  element :expenses, "#claim_assessment_attributes_expenses"
  element :authorised, "label[for='claim_state_authorised']"
  element :update, "input#button.button"
  element :refused, "label[for='claim_state_refused']"
  element :rejected, "label[for='claim_state_rejected']"

  section :rejection_reasons, 'div.js-cw-claim-rejection-reasons' do
    element :first_reason, 'label[for="_state_reason_no_indictment"]'
  end

  section :refusal_reasons, 'div.js-cw-claim-refuse-reasons' do
    element :first_reason, 'label[for="_state_reason_duplicate_claim"]'
  end

  section :messages_panel, "#claim-accordion .messages-container" do
    element :enter_your_message, "textarea#message_body"
    element :send, "form#new_message div.submit-column > input.button-secondary"

    def upload_file(path)
      attach_file("message_attachment", path)
    end
  end
end
