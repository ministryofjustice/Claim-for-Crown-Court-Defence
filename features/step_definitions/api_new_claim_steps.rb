Given(/^I create a draft claim marked as from API$/) do
  claim = FactoryGirl.create(:draft_claim, source: 'api', advocate: @advocate)
  claim.defendants.each { |defendant| defendant.destroy! }
end