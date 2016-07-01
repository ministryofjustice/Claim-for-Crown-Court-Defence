class ClaimShowPage < SitePrism::Page
  section :nav, "div.primary-nav-bar > nav > ul" do
    element :your_claims, "li:nth-of-type(1) > a"
    element :archive, "li:nth-of-type(2) > a"
  end

  element :status, "div.claim-hgroup > div.claim-status > span.state"
  element :messages_tab, "#claim-accordion > h2.tab:nth-of-type(1)"
  element :edit_this_claim, "div.claim-detail-actions a:nth-of-type(1)"

  section :messages_panel, "#claim-accordion > div.panel:nth-of-type(1)" do
    element :enter_your_message, "textarea#message_body"
    element :send, "form#new_message div.submit-column > input.button-secondary"
    element :fees, "#claim_assessment_attributes_fees"
    element :expenses, "#claim_assessment_attributes_expenses"
    element :authorised, "#claim_state_authorised"
    element :rejected, "#claim_state_rejected"
    element :update, "input#button.button"

    section :rejection_reasons, 'div.js-cw-claim-rejection-reasons' do
      element :first_reason, 'label:nth-of-type(1) input:nth-of-type(1)'
    end

    def upload_file(path)
      attach_file("message_attachment", path)
    end
  end
end
