namespace :claims do

  desc "Delete all dummy docs after dropping the DB"
  task :delete_docs do
    FileUtils.rm_rf('./features/examples/000')
  end

  desc "Create demo claim data for all states, allocating to case work as required"
  task :demo_data => :environment do

    example_advocate = Advocate.find(1)
    example_case_worker = CaseWorker.find(1)

    create_claims_for(example_advocate,example_case_worker)
    create_advocates_for(example_advocate.chamber)

  end

  def add_fees_expenses_and_defendant(claim)
    rand(1..10).times { claim.fees << FactoryGirl.create(:fee, :random_values, claim_id: claim.id, fee_type_id: FeeType.all.sample(1)[0].id) }
    rand(1..10).times { claim.expenses << FactoryGirl.create(:expense, :random_values, claim_id: claim.id, expense_type_id: ExpenseType.all.sample(1)[0].id) }
    claim.defendants << FactoryGirl.create(:defendant, claim_id: claim.id)
  end

  def add_document(claim)
    file = File.open("./features/examples/longer_lorem.pdf")
    Document.create!(claim_id: claim.id, document_type_id: 1, document: file, document_content_type: 'application/pdf' )
  end

  #
  # create 3 claims of each state (execept deleted)
  # for demo advocate.
  # i.e. John Smith: advocate@eample.com (id of 1)
  #
  def create_claims_for(advocate,case_worker,claims_per_state=3)
    Claim.state_machine.states.map(&:name).each do |s|
      next if s == :deleted
      claims_per_state.times do
          claim = FactoryGirl.create("#{s}_claim".to_sym, advocate: advocate, court: Court.all.sample, offence: Offence.all.sample)
          puts(" - created #{s} claim for advocate #{advocate.first_name} #{advocate.last_name}")
          add_fees_expenses_and_defendant(claim)
          add_document(claim)

          # all states but those below require allocation to case worker
          unless [:draft,:archived_pending_delete].include?(s)
            case_worker.claims << claim
            puts "  - allocating to #{case_worker.user.email}"
          end
      end
    end
  end

  #
  # create n to n+10 random advocates BUT for the same firm as the
  # that of the example advocate above i.e.'Test chamber/firm'
  #
  def create_advocates_for(chamber,minimum=20)
    rand(minimum..minimum+10).times do
        a = FactoryGirl.create(:advocate, chamber: chamber)
        puts(" - created advocate #{a.first_name} #{a.last_name}, login: #{a.user.email}/#{a.user.password}")
    end
  end

end
