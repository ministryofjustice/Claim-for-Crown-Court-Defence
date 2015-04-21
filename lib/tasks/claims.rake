namespace :claims do

  desc "Create submitted claims with random fees, random expenses and one defendant"
  task :submitted, [:number] => :environment do |task, args|
    args[:number].to_i.times { FactoryGirl.create(:submitted_claim) }
    claims = Claim.last(args[:number])
    claims.each do |claim|
      rand(1..10).times { claim.fees << FactoryGirl.create(:fee, :random_values, claim_id: claim.id) }
      rand(1..10).times { claim.expenses << FactoryGirl.create(:expense, :random_values, claim_id: claim.id) }
      claim.defendants << FactoryGirl.create(:defendant, claim_id: claim.id)
    end
  end

  desc "Create draft claims with random fees, random expenses and one defendant"
  task :draft, [:number] => :environment do |task, args|
    args[:number].to_i.times { FactoryGirl.create(:claim) }
    claims = Claim.last(args[:number])
    claims.each do |claim|
      rand(1..10).times { claim.fees << FactoryGirl.create(:fee, :random_values, claim_id: claim.id) }
      rand(1..10).times { claim.expenses << FactoryGirl.create(:expense, :random_values, claim_id: claim.id) }
      claim.defendants << FactoryGirl.create(:defendant, claim_id: claim.id)
    end
  end

  desc "Create claims allocated to caseworker@example.com, with random fees, random expenses and one defendant"
  task :allocated, [:number] => :environment do |task, args|
    args[:number].to_i.times { FactoryGirl.create(:submitted_claim) }
    claims_to_allocate = Claim.last(args[:number])
    case_worker = User.find_by(email: 'caseworker@example.com')
    claims_to_allocate.each do |claim|
      rand(1..10).times { claim.fees << FactoryGirl.create(:fee, :random_values, claim_id: claim.id) }
      rand(1..10).times { claim.expenses << FactoryGirl.create(:expense, :random_values, claim_id: claim.id) }
      case_worker.claims_to_manage << claim
      claim.defendants << FactoryGirl.create(:defendant, claim_id: claim.id)
    end
  end

  desc "Create completed claims, with random fees, random expenses and one defendant"
  task :completed, [:number] => [:environment, :allocated] do |task, args|
    args[:number].to_i.times { FactoryGirl.create(:completed_claim) }
    claims = Claim.last(args[:number])
    case_worker = User.find_by(email: 'caseworker@example.com')
    claims.each do |claim|
      rand(1..10).times { claim.fees << FactoryGirl.create(:fee, :random_values, claim_id: claim.id) }
      rand(1..10).times { claim.expenses << FactoryGirl.create(:expense, :random_values, claim_id: claim.id) }
      case_worker.claims_to_manage << claim
      claim.defendants << FactoryGirl.create(:defendant, claim_id: claim.id)
    end
  end

  desc "Create draft, submitted, allocated and completed claims with random fees, random expenses and one defendant"
  task :all_states, [:number] => [:environment, :submitted, :draft, :allocated, :completed] do |task, args|
  end

end