Then(/^I should see "(.*?)" in top cell of column with link "(.*?)"$/) do |cell_value, link_text|
  within('.report') do
    link = find_link link_text
    column = last_xpath_index(link.path)
    top_cell = find(:xpath, "./tbody/tr[1]/td[#{column}]")
    expect(top_cell.text).to eq cell_value
  end
end