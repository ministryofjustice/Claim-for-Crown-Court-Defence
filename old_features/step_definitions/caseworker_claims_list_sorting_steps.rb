Given(/^(\d+) sortable claims have been assigned to me$/) do |count|
  Timecop.freeze(Date.parse('11/01/2016')) do
    count.to_i.times do |n|
      Timecop.freeze(n.days.ago) do
        n = n+1
        chr = (n+64).chr
        claim = create(:allocated_claim, case_number: "A#{(n).to_s.rjust(8,"0")}", case_type: FactoryBot.build(:case_type, name: "Case Type #{chr}") )
        claim.external_user.user.update(last_name: "Smith-#{chr}", first_name: 'Billy')
        claim.fees.destroy_all
        claim.expenses.destroy_all
        create(:misc_fee, claim: claim, quantity: n*1, rate: n*1)
        @case_worker.claims << claim
      end
    end
  end
end
