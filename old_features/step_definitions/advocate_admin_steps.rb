Then(/^I should see all advocates?$/) do
  @advocates = @advocate.provider.external_users.ordered_by_last_name

  within('.report') do
    #For each row in the report
    page.all('tbody tr').each_with_index do |row, index|
      advocate = @advocates[index]
      first_name = advocate.user.first_name
      last_name = advocate.user.last_name

      #Check the first columns value
      expect(row.find('td[1]')).to have_content(last_name)
      #Check the second columns value
      expect(row.find('td[2]')).to have_content(first_name)
    end
  end
end

When(/^I search for an advocate/) do
  fill_in 'search', with: "#{@advocate.user.first_name} #{@advocate.user.last_name}"
  click_button 'Search'
end

Then(/^I should see the advocate in the results$/) do
  within('.report') do
    #For each row in the report
    page.all('tbody tr').each_with_index do | row, index |

      first_name = @advocate.user.first_name
      last_name = @advocate.user.last_name

      #Check the first columns value
      expect(row.find('td[1]')).to have_content(last_name)
      #Check the second columns value
      expect(row.find('td[2]')).to have_content(first_name)
    end
  end
end
