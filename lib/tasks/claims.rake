# EXAMPLE_DOC_TYPES is a hash of example files (locates in spec/fixtures/files) and their doctype
#
EXAMPLE_DOC_TYPES = {
  'repo_order_1.pdf'                      => 1,
  'repo_order_2.pdf'                      => 1,
  'repo_order_3.pdf'                      => 1,
  'LAC_1.pdf'                             => 2,
  'commital_bundle.pdf'                   => 3,
  'indictment.pdf'                        => 4,
  'judicial_appointment_order.pdf'        => 5,
  'invoices.pdf'                          => 6,
  'hardship.pdf'                          => 7,
  'previous_fee_advancements.pdf'         => 8,
  'other_supporting_evidence.pdf'         => 9,
  'justification_for_late_submission.pdf' => 10
}


namespace :claims do

  desc "Delete all dummy docs after dropping the DB"
  task :delete_docs do
    FileUtils.rm_rf('./public/assets/dev/images/')
    FileUtils.rm_rf('./public/assets/test/images/')
  end

  desc "seed data - a dependency of the demo_data task"
  task :seed_data => :environment do
    # NOTE: seed data SHOULD be idempotent
    begin
      env_seed_file = File.join(Rails.root, 'db', 'seeds.rb')
      load(env_seed_file) if File.exist?(env_seed_file)
    rescue Exception => e
      puts "ERROR: seed_data task raised error - #{e.message}"
      raise e
    end
  end

  desc "Create demo claim data for specified states (default: all, delimited by ;), allocating to case work as required"
  task :demo_data, [:advocate_count, :claims_per_state, :states_to_add ] => [:environment, :seed_data] do |task, args|
      begin
        args.with_defaults(:advocate_count => 4, :claims_per_state => 3, :states_to_add => 'all')

        ADVOCATE_COUNT = args[:advocate_count].to_i
        CLAIMS_PER_STATE = args[:claims_per_state].to_i

        states = parse_states_from_string(args[:states_to_add])

        puts "CREATING: creating #{ADVOCATE_COUNT} additional advocate(s) and #{CLAIMS_PER_STATE} claims per state (below)"
        puts "states: #{states.to_s}"
        puts "-----------------------------------------------------------------------------------------------------------------------------"

        example_advocate = Advocate.find(1)
        example_case_worker = CaseWorker.find(1)

        create_claims_for(example_advocate,example_case_worker,CLAIMS_PER_STATE,states)
        create_advocates_and_claims_for(example_advocate.chamber,example_case_worker,ADVOCATE_COUNT,CLAIMS_PER_STATE,states)

      rescue Exception => e
        puts "ERROR: demo_data task raised an error - #{e.message}"
        raise e
      end
  end

  def add_basic_fees(claim)
    #
    # add all basic fee types with random values (incl none)
    # to some
    # NOTE: at time of writing a claim has all initial fees"
    #       instatiated at point of new claim creation.
    #

    FeeType.basic.each do |fee_type|
      q = 0
      r = 0
      if rand(3) != 0
        q = rand(1..100)
        r = rand(1.00..40.00).round(2)
      end
      fee = FactoryGirl.create(:fee, quantity: q, rate: r , claim: claim, fee_type: fee_type)
      FactoryGirl.create(:date_attended, fee: fee) unless rand(2) == 0
      end
    end
  end

  def add_fixed_misc_fees(claim)
    #
    # 1 to 5 fixed/misc fees per claim
    # and of those some should have a date attended FROM
    # NOTE: some of these will be given a date attended TO
    # by the factory
    #
    rand(1..5).times do
        fee = FactoryGirl.create(:fee, :random_values, claim: claim, fee_type:)
      FactoryGirl.create(:date_attended, fee: fee) unless rand(2) == 0
    end

  end

  def add_expenses(claim)
    rand(1..10).times { FactoryGirl.create(:expense, :random_values, claim: claim, expense_type: ExpenseType.all.sample) }
  end

  def add_defendants(claim)
    claim.defendants << FactoryGirl.create(:defendant, claim: claim)
  end

  def add_other_data(claim)
    add_basic_fees(claim)
    add_fixed_misc_fees(claim)
    add_expenses(claim)
    add_defendants(claim)
  end

  def add_documentary_evidence(claim,doc_count=2)

    #
    # Attach example evidence <doc_count> times. Randomly choose a document to add and
    # check the appropriate evidence checklist checkbox
    #

    checklist_ids = []

    doc_count.times do |i|
      pdf_name = EXAMPLE_DOC_TYPES.keys[rand(EXAMPLE_DOC_TYPES.size)]
      checklist_ids << EXAMPLE_DOC_TYPES[pdf_name]
      filename = "#{Rails.root}/spec/fixtures/files/#{pdf_name}"
      file = File.open(filename)

      FactoryGirl.create(:document,
                          claim: claim,
                          document: file,
                          document_content_type: 'application/pdf',
                          advocate: claim.advocate
                        )
    end
    checklist_ids
  end

  def parse_states_from_string(states_delimited_string)
    #
    # if states string is 'all' or blank use all valid states
    # otherwise check and remove any invalid states
    #
    states = []
    all_valid_states = Claim.state_machine.states.map(&:name)

    if states_delimited_string == 'all' || states_delimited_string.blank?
      states = all_valid_states
    else
      states = states_delimited_string.gsub(/\s+/,'').split(';').map { |s| s.to_sym }

      # must loop through a non-changing array as delete will effect looping
      invalid_states = []
      states.each do |s|
        if !all_valid_states.include?(s)
            puts "WARNING: #{s} is not a valid state and will be ignored!"
            invalid_states << s
        end
      end
    end

    return invalid_states.nil? ? states : states - invalid_states

  end

  #
  # create specified (default:3) claims of each state (except deleted)
  # for demo advocate.
  # i.e. John Smith: advocate@eample.com (id of 1)
  #
  def create_claims_for(advocate,case_worker,claims_per_state=3,states_to_add)

    states_to_add.each do |s|
      next if s == :deleted
      claims_per_state.times do

          # randomise creator
          claim = nil
          if rand(2) == 1
            claim = FactoryGirl.create("#{s}_claim".to_sym, :admin_creator, advocate: advocate, court: Court.all.sample, offence: Offence.all.sample)
          else
            claim = FactoryGirl.create("#{s}_claim".to_sym, advocate: advocate, court: Court.all.sample, offence: Offence.all.sample )
          end

          puts("   - created #{s} claim as #{claim.creator.first_name} #{claim.creator.last_name} for advocate #{advocate.first_name} #{advocate.last_name}")
          add_other_data(claim)
          checklist_ids = add_documentary_evidence(claim, 1 + rand(6) )
          claim.update_attribute(:evidence_checklist_ids, checklist_ids)

          # all states but those below require allocation to case worker
          unless [:draft,:archived_pending_delete,:submitted].include?(s)
            case_worker.claims << claim
            puts "     - allocating to #{case_worker.user.email}"
          end
      end
    end
  end

  #
  # 1. create random advocates BUT for the same firm as the
  # that of the example advocate and advocate-admin
  # above (i.e.'Test chamber/firm') and optionally
  # specify number of claims per advocate and number
  # of states per claim to generate and for each advocate
  #
  def create_advocates_and_claims_for(chamber, case_worker, advocate_count=4, claims_per_advocate_per_state=2, states_to_add)
    advocate_count.times do
        advocate = FactoryGirl.create(:advocate, chamber: chamber)
        puts(" + created advocate #{advocate.first_name} #{advocate.last_name}, login: #{advocate.user.email}/#{advocate.user.password}")
        create_claims_for(advocate,case_worker,claims_per_advocate_per_state, states_to_add)
    end
  end

end
