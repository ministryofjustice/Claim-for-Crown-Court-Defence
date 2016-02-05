Given(/^I have (\d+) sortable claims$/) do |count|
  Timecop.freeze(Date.parse('11/01/2016')) do
    states = [:draft, :submitted, :allocated, :authorised, :rejected]
    count.to_i.times do |i|
      Timecop.freeze(i.days.ago) do
        n = i+1
        chr = (n+64).chr
        advocate = create(:external_user, provider: @advocate.provider)
        advocate.user.update(last_name: "Smith-#{chr}", first_name: 'Billy')
        claim = create("#{states[i%states.size]}_claim".to_sym, external_user: advocate, case_number: "A#{(n).to_s.rjust(8,"0")}")
        claim.fees.destroy_all
        claim.expenses.destroy_all
        create(:fee, claim: claim, quantity: n*1, rate: n*1)
        claim.assessment.update_values!(claim.fees_total, 0) if claim.authorised?
      end
    end
  end
end
