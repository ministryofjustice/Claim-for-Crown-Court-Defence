Then(/^I (.*?) see supplier number$/) do | supplier_number_expectation |
  case supplier_number_expectation
    when 'should'
      within('#provider-form') do
        expect(find(:css, "#js-supplier-number")).to be_visible
      end
    when 'should not'
      within('#provider-form') do
        expect(page).not_to have_css('#js-supplier-number')
      end
  end
end

Then(/^I (.*?) see vat registered$/) do | vat_registered_expectation |
  case vat_registered_expectation
    when 'should'
      within('#provider-form') do
        expect(find(:css, "#js-vat-registered")).to be_visible
      end
    when 'should not'
      within('#provider-form') do
        expect(page).not_to have_css("#js-vat-registered")
      end
  end
end

When(/^I click on (.*?) provider type$/) do | radio_button|
  within('#provider-form') do
    choose radio_button
  end
end
