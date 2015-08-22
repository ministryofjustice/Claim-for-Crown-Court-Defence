Given(/^the claim has additional information$/) do
  @claim.update_column(:additional_information, 'Lorem ipsum')
end

Then(/^I should (not )?see the additional information$/) do |negate|
  within '#summary' do
    if negate
      expect(page).to_not have_content('Additional information')
      expect(page).to_not have_content('Lorem ipsum')
    else
      expect(page).to have_content('Additional information')
      expect(page).to have_content('Lorem ipsum')
    end
  end
end
