namespace :provider  do
  desc "Debug task for provider"
  task :switch, [:claim_id] => :environment do | _task, args|
    claim_id = args[:claim_id]
    ProviderSwitcher.new(claim_id).switch!
  end

  task :reset => :environment do
    ProviderSwitcher.new.reset!
  end
end


class ProviderSwitcher
  def initialize(claim_id = nil)
    @claim_id = claim_id
  end

  def switch!
    claim = Claim::BaseClaim.active.find(@claim_id)
    provider = claim.provider

    user = User.where(email: 'advocateadmin@example.com').first
    external_user = user.persona
    external_user.provider_id = provider.id
    external_user.save!
    puts "Test user switched to belong to Provider #{provider.id}  #{provider.name}"
  end

  def reset!
    advocate_external_user = User.active.where(email: 'advocate@example.com').first.persona
    admin_external_user = User.active.where(email: 'advocateadmin@example.com').first.persona
    admin_external_user.provider_id = advocate_external_user.provider_id
    admin_external_user.save!
    puts "Test user reset to belong to Provider #{admin_external_user.provider_id} #{admin_external_user.provider.name}"
  end
end
