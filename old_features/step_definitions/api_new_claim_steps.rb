Given(/^I create a draft claim marked as from API$/) do
  claim = FactoryBot.create(:draft_claim, source: 'api', external_user: @advocate)
  claim.defendants.each { |defendant| defendant.destroy! }
end