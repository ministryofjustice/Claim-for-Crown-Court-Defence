namespace :claims do

  desc "Generate claims with state: SUBMITTED"
  task :submitted, [:number] => :environment do |task, args|
    args[:number].to_i.times { FactoryGirl.create(:submitted_claim) }
  end

  desc "Generate claims with state: DRAFT"
  task :draft, [:no_to_create] => :environment do |task, args|
    args[:number].to_i.times { FactoryGirl.create(:claim) }
  end

  desc "Generate claims and ALLOCATE ALL to caseworker@example.com"
  task :allocated, [:number] => :environment do |task, args|
    args[:number].to_i.times { FactoryGirl.create(:submitted_claim) }
    claims_to_allocate = Claim.last(args[:number])
    case_worker = User.find_by(email: 'caseworker@example.com')
    claims_to_allocate.each do |claim|
      case_worker.claims_to_manage << claim
    end
  end

  desc "Generate claims of DRAFT, SUBMITTED and ALLOCATED states"
  task :all_states, [:number] => [:environment, :submitted, :draft, :allocated] do |task, args|
  end

end