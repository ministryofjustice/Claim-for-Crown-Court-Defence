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

STATES_TO_ADD_EVIDENCE_FOR = ['allocated',
                              'submitted',
                              'paid',
                              'redetermination',
                              'part_paid',
                              'awaiting_further_info',
                              'awaiting_info_from_court']

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
  task :demo_data, [:additional_advocates, :claims_per_state, :states_to_add, :additional_caseworkers] => [:environment, :seed_data] do |task, args|
      begin
        args.with_defaults(:additional_advocates => 4, :claims_per_state => 3, :states_to_add => 'all', :additional_caseworkers => 55)

        ADVOCATE_COUNT = args[:additional_advocates].to_i
        CLAIMS_PER_STATE = args[:claims_per_state].to_i
        CASEWORKER_COUNT = args[:additional_caseworkers].to_i

        caseworker_count_per_location = (CASEWORKER_COUNT/2).round(0)
        states = parse_states_from_string(args[:states_to_add])

        puts "CREATING: creating #{ADVOCATE_COUNT} additional advocate(s) and #{CLAIMS_PER_STATE} claims per state (below)"
        puts "states: #{states.to_s}"
        puts "-----------------------------------------------------------------------------------------------------------------------------"

        example_advocate = Advocate.find(1)
        example_case_worker = CaseWorker.find(1)

        # removed as adding seeds of real case workers instead - could be used in addition to this in future
        # create_dummy_caseworkers(caseworker_count_per_location,Location.first)
        # create_dummy_caseworkers(caseworker_count_per_location,Location.second)

        create_claims_for(example_advocate,example_case_worker,CLAIMS_PER_STATE,states)
        create_advocates_and_claims_for(example_advocate.chamber,example_case_worker,ADVOCATE_COUNT,CLAIMS_PER_STATE,states)

      rescue Exception => e
        puts "ERROR: demo_data task raised an error - #{e.message}"
        raise e
      end
  end

# add case workers at a specific location with email reflecting name and location
def create_dummy_caseworkers(caseworkers_to_add, location)
  caseworkers_to_add.times do
    cw = FactoryGirl.create(:case_worker, location: location)
    puts "+ created case worker #{cw.first_name} #{cw.last_name} with email #{cw.email} for location #{location.name}"
  end
end


  # adds all initial fees, "Basic Fee" qauntity is always 1,
  # others random q and a and dates only for those applicable.
  #
  # NOTE: at time of writing a claim has all "initial fees"
  #       instantiated at point of new claim creation.

 def random_basic_fee_quantity_and_amount_by_type(fee_type)
    case fee_type.code
      when 'BAF'
        q = 1
        a = rand(1500.00..3000.00)
      when 'DAF'
        q = rand(1..15)
        a = rand(200..2500)
      when 'DAH'
        q = rand(0..20)
        a = rand(200.00..3000.00)
      when 'DAJ'
        q = rand(0..10)
        a = rand(200.00..800.00)
      when 'PCM'
        q = rand(2..10)
        a = rand(200..600)
      when 'PPE'
        q = rand(50..200)
        a = rand(0.50..400.00)
      when 'CAV'
        q = rand(3..20)
        a = rand(40.00..500.00)
      when 'NPW'
        q = rand(11..300)
        a = rand(30.00..400.00)
      when 'SAF'
        q = rand(5..15)
        a = rand(380.00..900.00)
      else
        q = rand(1..15);
        a = rand(10.00..1199.00)
    end

    return q, a.round(2)
 end

  def add_basic_fees(claim)
    return if claim.case_type == "fixed_fee"

    FeeType.basic.each do |fee_type|
      q, a = random_basic_fee_quantity_and_amount_by_type(fee_type)
      unless fee_type.code == 'BAF'
        if rand(2) == 0
          q = 0
          a = 0
        end
      end

      # TODO: this will need to be an update if instantiation id kept
      # fee = FactoryGirl.create(:fee, quantity: q, amount: a, claim: claim, fee_type: fee_type)

      fee = Fee.find_by(claim: claim, fee_type: fee_type)
      fee.quantity = q
      fee.amount = a
      fee.save!

      if ['BAF','DAF','DAH','DAJ','PCM','SAF'].include?(fee.fee_type.code)
        FactoryGirl.create(:date_attended, attended_item: fee) unless rand(2) == 0 || q == 0
      end

    end
  end

  # add 1 to 6 fixed/misc fees, some with date
  def add_fixed_misc_fees(claim, fee_count=nil)
    fee_count = fee_count.nil? ? rand(1..6) : fee_count
    fee_count.times do
      fee_type = claim.case_type == "fixed_fee" ? FeeType.fixed.sample : FeeType.misc.sample
      fee = FactoryGirl.create(:fee, :random_values, claim: claim, fee_type: fee_type)
      FactoryGirl.create(:date_attended, attended_item: fee) unless rand(2) == 0
      # puts "            + creating fee of category #{fee.fee_type.fee_category.abbreviation} and type #{fee.fee_type.description}"
    end
  end

  def add_expenses(claim)
    rand(1..10).times do
      expense = FactoryGirl.create(:expense, :random_values, claim: claim, expense_type: ExpenseType.all.sample)
      FactoryGirl.create(:date_attended, attended_item: expense) unless rand(2) == 0
    end
  end

  def push_fees_over_threshold(claim)
    until claim.calculate_total.to_f >= 20000.00
      add_fixed_misc_fees(claim, 1)
    end
  end

  def add_defendants(claim)
    claim.defendants << FactoryGirl.create(:defendant, claim: claim)
  end

  def add_other_data(claim)
    add_basic_fees(claim)
    add_fixed_misc_fees(claim)
    add_expenses(claim)

    #attempt to force ~25%% of claims to have random values over 20k threshold
    push_fees_over_threshold(claim) if rand(4) == 1

    add_defendants(claim)
    add_documentary_evidence(claim, rand(1..2)) # WARNING: adding evidence can significantly slow travis and deploy process and eat network trvis (i.e. cost??)
  end

  def add_documentary_evidence(claim,doc_count=2)
    #
    # Attach example evidence <doc_count> times but only for
    # particular states. Randomly choose a document to add and
    # check the appropriate evidence checklist checkbox
    #
    return unless STATES_TO_ADD_EVIDENCE_FOR.include?(claim.state)
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

    claim.update_attribute(:evidence_checklist_ids, checklist_ids)

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
        claim = nil
        case_type = CaseType.all.sample
        claim_attrs = {
            advocate:    advocate,
            court:      Court.all.sample,
            offence:    Offence.all.sample,
            scheme:     Scheme.all.sample,
            case_type:  case_type}
        if case_type.requires_cracked_dates?
          claim_attrs.merge!({trial_fixed_notice_at: 2.months.ago, trial_fixed_at: 1.month.ago, trial_cracked_at: 2.week.ago})
        end
        claim = FactoryGirl.create("#{s}_claim".to_sym, claim_attrs)

        # randomise creator
        if rand(2) == 1
          advocate_admin = claim.advocate.chamber.advocates.where(role:'admin').sample
          advocate_admin ||= create(:advocate, :admin, chamber: claim.advocate.chamber)
          claim.creator = advocate_admin
        end

        puts("   - created #{s} claim as #{claim.creator.first_name} #{claim.creator.last_name} for advocate #{advocate.first_name} #{advocate.last_name}")
        add_other_data(claim)

        # all states but those below require allocation to case worker
        unless [:draft,:archived_pending_delete,:submitted, :redetermination].include?(s)
          case_worker.claims << claim
          puts "     - allocating to #{case_worker.user.email}"
        end

        claim.apply_vat = !(claim.id % 3 == 0)
        claim.save!
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
