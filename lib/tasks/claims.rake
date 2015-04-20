namespace :claims do

  desc "Create submitted claims with random fees"
  task :submitted, [:number] => :environment do |task, args|
    args[:number].to_i.times { FactoryGirl.create(:submitted_claim) }
    claims = Claim.last(args[:number])
    claims.each do |claim|
      claim.fees << FactoryGirl.build(:fee, :random_values)
    end
  end

  desc "Create draft claims with random fees"
  task :draft, [:number] => :environment do |task, args|
    args[:number].to_i.times { FactoryGirl.create(:claim) }
    claims = Claim.last(args[:number])
    claims.each do |claim|
      claim.fees << FactoryGirl.build(:fee, :random_values)
    end
  end

  desc "Create claims, with random fees, and allocate all to caseworker@example.com"
  task :allocated, [:number] => :environment do |task, args|
    args[:number].to_i.times { FactoryGirl.create(:submitted_claim) }
    claims_to_allocate = Claim.last(args[:number])
    case_worker = User.find_by(email: 'caseworker@example.com')
    claims_to_allocate.each do |claim|
      claim.fees << FactoryGirl.build(:fee, :random_values)
      case_worker.claims_to_manage << claim
    end
  end

  desc "Create claims of draft, submitted and allocated states - same number of each, all with random fees"
  task :all_states, [:number] => [:environment, :submitted, :draft, :allocated] do |task, args|
  end

end