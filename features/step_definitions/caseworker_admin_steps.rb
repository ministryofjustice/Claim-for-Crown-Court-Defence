Then(/^I should see all case workers$/) do

  @case_workers << @case_worker

  @case_workers.sort!{ |a, b| a.user.last_name != b.user.last_name ? a.user.last_name <=> b.user.last_name : a.user.first_name <=> b.user.first_name}

  within('.report') do
    #For each row in the report
    page.all('tbody tr').each_with_index do | row, index |

      case_worker = @case_workers[index]
      first_name = case_worker.user.first_name
      last_name = case_worker.user.last_name

      #Check the first columns value
      expect(row.find('td[1]')).to have_content(last_name)
      #Check the second columns value
      expect(row.find('td[2]')).to have_content(first_name)
    end
  end
end

When(/^I search for a case worker/) do
  fill_in 'search', with: "#{@case_worker.user.first_name} #{@case_worker.user.last_name}"
  click_button 'Search'
end

Then(/^I should see the case worker in the results$/) do
  within('.report') do
    #For each row in the report
    page.all('tbody tr').each_with_index do | row, index |

      first_name = @case_worker.user.first_name
      last_name = @case_worker.user.last_name

      #Check the first columns value
      expect(row.find('td[1]')).to have_content(last_name)
      #Check the second columns value
      expect(row.find('td[2]')).to have_content(first_name)
    end
  end
end
