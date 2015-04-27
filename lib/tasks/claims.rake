namespace :claims do

  desc "Create submitted claims with random fees, random expenses and one defendant"
  task :submitted, [:number] => :environment do |task, args|
    args[:number].to_i.times { FactoryGirl.create(:submitted_claim, court_id: random_court_id) }
    claims = Claim.last(args[:number])
    claims.each do |claim|
      add_fees_expenses_and_defendant(claim)
    end
  end

  desc "Create draft claims with random fees, random expenses and one defendant"
  task :draft, [:number] => :environment do |task, args|
    args[:number].to_i.times { FactoryGirl.create(:claim, court_id: random_court_id) }
    claims = Claim.last(args[:number])
    claims.each do |claim|
      add_fees_expenses_and_defendant(claim)
    end
  end

  desc "Create claims allocated to caseworker@example.com, with random fees, random expenses and one defendant"
  task :allocated, [:number] => :environment do |task, args|
    args[:number].to_i.times { FactoryGirl.create(:submitted_claim, court_id: random_court_id) }
    claims = Claim.last(args[:number])
    claims.each do |claim|
      add_fees_expenses_and_defendant(claim)
      allocate(claim, 'caseworker@example.com')
    end
  end

  desc "Create completed claims, with random fees, random expenses and one defendant"
  task :completed, [:number] => :environment do |task, args|
    args[:number].to_i.times { FactoryGirl.create(:completed_claim, court_id: random_court_id) }
    claims = Claim.last(args[:number])
    claims.each do |claim|
      add_fees_expenses_and_defendant(claim)
      allocate(claim, 'caseworker@example.com')
    end
  end

  desc "Create draft, submitted, allocated and completed claims with random fees, random expenses and one defendant"
  task :all_states, [:number] => [:submitted, :draft, :allocated, :completed] do |task, args|
  end

  def random_court_id
    Court.all.sample(1)[0].id
  end

  def add_fees_expenses_and_defendant(claim)
    rand(1..10).times { claim.fees << FactoryGirl.create(:fee, :random_values, claim_id: claim.id, fee_type_id: FeeType.all.sample(1)[0].id) }
    rand(1..10).times { claim.expenses << FactoryGirl.create(:expense, :random_values, claim_id: claim.id, expense_type_id: ExpenseType.all.sample(1)[0].id) }
    claim.defendants << FactoryGirl.create(:defendant, claim_id: claim.id)
  end

  def allocate(claim, caseworker_email)
    caseworker = User.find_by(email: caseworker_email).rolable
    caseworker.claims << claim
  end
end
