# frozen_string_literal: true

When('I click "Continue" in the claim form and accept "no indictment" popup') do
  accept_confirm(no_indictment_message) do
    @claim_form_page.continue_button.click
  end
end

When('I click "Continue" in the claim form and dismiss "no indictment" popup') do
  dismiss_confirm(no_indictment_message) do
    @claim_form_page.continue_button.click
  end
end

def no_indictment_message
  @no_indictment_message ||= "The evidence checklist suggests that no indictment has been attached.\n" +
                             "This can lead to your claim being rejected.\n\n" +
                             "Do you wish to proceed without attaching an indictment?"
end
