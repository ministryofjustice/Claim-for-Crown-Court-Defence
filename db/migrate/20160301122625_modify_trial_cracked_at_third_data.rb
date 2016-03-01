class ModifyTrialCrackedAtThirdData < ActiveRecord::Migration
  def up
    Claim::BaseClaim.where.not(trial_cracked_at_third: nil).each do |claim|
      clean_trial_cracked_at_third = claim.trial_cracked_at_third.downcase.strip.gsub(/\s/,'_')
      puts "WARNING: #{clean_trial_cracked_at_third} for claim (id: #{claim.id}) does not match expected value after cleaning" unless Settings.trial_cracked_at_third.include?(clean_trial_cracked_at_third)
      claim.update_column(:trial_cracked_at_third, clean_trial_cracked_at_third)
    end
  end

  def down
    Claim::BaseClaim.where.not(trial_cracked_at_third: nil).each do |claim|
      claim.update_column(:trial_cracked_at_third, claim.trial_cracked_at_third.humanize)
    end
  end
end
