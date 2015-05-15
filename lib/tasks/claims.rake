namespace :claims do

  desc "Delete all dummy docs after dropping the DB"
  task :delete_docs do
    FileUtils.rm_rf('./features/examples/000')
  end

  task :seed_data => :environment do
    # NOTE: seed data SHOULD be idempotent
    begin
      env_seed_file = File.join(Rails.root, 'db', 'seeds.rb')
      load(env_seed_file) if File.exist?(env_seed_file)
    rescue Exception => e
      puts "ERROR: seed_data task raise error - #{e.message}"
      raise e
    end
  end

  desc "Create demo claim data for all states, allocating to case work as required"
  task :demo_data => [:environment, :seed_data] do
      begin
        ADVOCATE_COUNT = 4
        CLAIMS_PER_ADVOCATE_PER_STATE = 3

        example_advocate = Advocate.find(1)
        example_case_worker = CaseWorker.find(1)

        create_claims_for(example_advocate,example_case_worker,CLAIMS_PER_ADVOCATE_PER_STATE)
        create_advocates_and_claims_for(example_advocate.chamber,example_case_worker,ADVOCATE_COUNT,CLAIMS_PER_ADVOCATE_PER_STATE)
        
      rescue Exception => e
        puts "ERROR: demo_data task raised an error - #{e.message}"
        raise e
      end
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
  # create specified (default:3) claims of each state (except deleted)
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
  # create random advocates BUT for the same firm as the
  # that of the example advocate and advocate-admin
  # above (i.e.'Test chamber/firm') and optionally
  # specify number of claims per advocate and number
  # of states per claim to generate and for each advocate
  #
  def create_advocates_and_claims_for(chamber, case_worker, advocate_count=3, max_claims_per_advocate_per_state=2)
    advocate_count.times do
        advocate = FactoryGirl.create(:advocate, chamber: chamber)
        puts(" - created advocate #{advocate.first_name} #{advocate.last_name}, login: #{advocate.user.email}/#{advocate.user.password}")

        random = rand(0..max_claims_per_advocate_per_state)
        random.times do
          create_claims_for(advocate,case_worker,random)
        end

    end
  end

end
