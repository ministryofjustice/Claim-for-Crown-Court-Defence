namespace :claims do

  desc "Delete all dummy docs after dropping the DB"
  task :delete_docs do
    FileUtils.rm_rf('./features/examples/000')
  end

  desc "Create submitted claims with random fees, expenses, offence and one defendant"
  task :submitted, [:number] => :environment do |task, args|
    args[:number].to_i.times { FactoryGirl.create(:submitted_claim, court: Court.all.sample, offence: Offence.all.sample) }
    claims = Claim.last(args[:number])
    claims.each do |claim|
      add_fees_expenses_and_defendant(claim)
      add_document(claim)
      report_created(:submitted, claim)
    end
  end

  desc "Create draft claims with random fees, expenses, offence and one defendant"
  task :draft, [:number] => :environment do |task, args|
    args[:number].to_i.times { FactoryGirl.create(:claim, court: Court.all.sample, offence: Offence.all.sample) }
    claims = Claim.last(args[:number])
    claims.each do |claim|
      add_fees_expenses_and_defendant(claim)
      add_document(claim)
      report_created(:draft, claim)
    end
  end

  desc "Create claims allocated to caseworker@example.com, with random fees, expenses, offence and one defendant"
  task :allocated, [:number] => :environment do |task, args|
    args[:number].to_i.times { FactoryGirl.create(:submitted_claim, court: Court.all.sample, offence: Offence.all.sample ) }
    claims = Claim.last(args[:number])
    claims.each do |claim|
      add_fees_expenses_and_defendant(claim)
      add_document(claim)
      allocate_claim(claim, 'caseworker@example.com')
      report_created(:allocated, claim)
    end
  end

  desc "Create completed claims, with random fees, expenses, offence and one defendant"
  task :completed, [:number] => :environment do |task, args|
    args[:number].to_i.times { FactoryGirl.create(:completed_claim, court: Court.all.sample, offence: Offence.all.sample) }
    claims = Claim.last(args[:number])
    claims.each do |claim|
      add_fees_expenses_and_defendant(claim)
      add_document(claim)
      allocate_claim(claim, 'caseworker@example.com')
      report_created(:completed, claim)
    end
  end

  desc "Create draft, submitted, allocated and completed claims with random fees, random expenses and one defendant"
  task :all_states, [:number] => [:submitted, :draft, :allocated, :completed] do |task, args|
  end

  def report_created(claim_type, claim)
    printf("Created %s claim: %s\n", claim_type.to_s, [claim.id, claim.state].join(', '))
  end

  def add_fees_expenses_and_defendant(claim)
    rand(1..10).times { claim.fees << FactoryGirl.create(:fee, :random_values, claim_id: claim.id, fee_type_id: FeeType.all.sample(1)[0].id) }
    rand(1..10).times { claim.expenses << FactoryGirl.create(:expense, :random_values, claim_id: claim.id, expense_type_id: ExpenseType.all.sample(1)[0].id) }
    claim.defendants << FactoryGirl.create(:defendant, claim_id: claim.id)
  end

  def add_document(claim)
    file = File.open("./features/examples/shorter_lorem.docx")
    Document.create!(claim_id: claim.id, document_type_id: 1, document: file, document_content_type: 'application/msword' )
  end

  def allocate_claim(claim, caseworker_email)
    caseworker = User.find_by(email: caseworker_email).persona
    caseworker.claims << claim
  end
end
