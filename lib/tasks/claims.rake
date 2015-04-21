namespace :claims do

  desc "Create submitted claims with random fees, random expenses and one defendant"
  task :submitted, [:number] => [:environment, :query_fee_and_expense_types] do |task, args|
    args[:number].to_i.times { FactoryGirl.create(:submitted_claim, court_id: random_court_id) }
    claims = Claim.last(args[:number])
    claims.each do |claim|
      add_fees_expenses_and_defendant(claim)
    end
  end

  desc "Create draft claims with random fees, random expenses and one defendant"
  task :draft, [:number] => [:environment, :query_fee_and_expense_types] do |task, args|
    args[:number].to_i.times { FactoryGirl.create(:claim, court_id: random_court_id) }
    claims = Claim.last(args[:number])
    claims.each do |claim|
      add_fees_expenses_and_defendant(claim)
    end
  end

  desc "Create claims allocated to caseworker@example.com, with random fees, random expenses and one defendant"
  task :allocated, [:number] => [:environment, :query_fee_and_expense_types] do |task, args|
    args[:number].to_i.times { FactoryGirl.create(:submitted_claim, court_id: random_court_id) }
    claims = Claim.last(args[:number])
    claims.each do |claim|
      add_fees_expenses_and_defendant(claim)
      allocate(claim, 'caseworker@example.com')
    end
  end

  desc "Create completed claims, with random fees, random expenses and one defendant"
  task :completed, [:number] => [:environment, :allocated, :query_fee_and_expense_types] do |task, args|
    args[:number].to_i.times { FactoryGirl.create(:completed_claim, court_id: random_court_id) }
    claims = Claim.last(args[:number])
    claims.each do |claim|
      add_fees_expenses_and_defendant(claim)
      allocate(claim, 'caseworker@example.com')
    end
  end

  desc "Create draft, submitted, allocated and completed claims with random fees, random expenses and one defendant"
  task :all_states, [:number] => [:environment, :submitted, :draft, :allocated, :completed] do |task, args|
  end

  task :query_fee_and_expense_types => :environment do
    @fee_types ||= FeeType.all
    @expense_types ||= ExpenseType.all
  end

  def random_court_id
    Court.all.sample(1)[0].id
  end

  def add_fees_expenses_and_defendant(claim)
    rand(1..10).times { claim.fees << FactoryGirl.create(:fee, :random_values, claim_id: claim.id, fee_type_id: @fee_types.sample(1)[0].id) }
    rand(1..10).times { claim.expenses << FactoryGirl.create(:expense, :random_values, claim_id: claim.id, expense_type_id: @expense_types.sample(1)[0].id) }
    claim.defendants << FactoryGirl.create(:defendant, claim_id: claim.id)
  end

  def allocate(claim, caseworker_email)
    caseworker = User.find_by(email: caseworker_email)
    caseworker.claims_to_manage << claim
  end

end