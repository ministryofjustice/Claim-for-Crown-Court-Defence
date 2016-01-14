Given(/^(\d+) sortable claims have been assigned to me$/) do |count|
  Timecop.freeze(Date.parse('11/01/2016')) do
    count.to_i.times do |n|
      Timecop.freeze(n.days.ago) do
        n = n+1
        chr = (n+64).chr
        claim = create(:allocated_claim, case_number: "A#{(n).to_s.rjust(8,"0")}", case_type: FactoryGirl.build(:case_type, name: "Case Type #{chr}") )
        claim.external_user.user.update(last_name: "Smith-#{chr}", first_name: 'Billy')
        claim.fees.destroy_all
        claim.expenses.destroy_all
        create(:fee, claim: claim, quantity: n*1, rate: n*1)
        @case_worker.claims << claim
      end
    end
  end
end

Then(/^I should see "(.*?)" in top cell of column (.*?)$/) do |cell_value, column_header|
  within('.report') do
    th = find(:xpath,"./thead/tr/th/a[contains(text(),#{column_header})]/..")
    column = th.path.slice(-2,1)
    top_cell = find(:xpath, "./tbody/tr[1]/td[#{column}]")
    expect(top_cell.text).to eq cell_value
  end
end
