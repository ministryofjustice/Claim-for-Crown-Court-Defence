# frozen_string_literal: true

# Utility class for bulk operations on external user account(s).
#
# Needs to be loaded and run in a rails console
# running an instance of the [CCCD application](https://github.com/ministryofjustice/Claim-for-Crown-Court-Defence)
#
# example:
#  accounts = AccountSetter.new(EMAILS)
#  accounts.report
#  accounts.soft_delete
#  accounts.un_soft_delete
#  accounts.change_password
#

class AccountSetter
  attr_reader :emails

  def initialize(emails)
    @emails = emails
  end

  # Find active or inactve accounts with matching email and
  # report basic information.
  #
  def report
    emails.each do |email|
      users = User.where(email: email)

      users.each do |user|
        puts "User #{user.email} with id #{user.id} have #{user.persona.provider.claims.count} claims for their provider, \"#{user.persona.provider.name}\""
      end
      puts("No users found for email #{email}".red) if users.empty?

      users = User.where('email LIKE ?', "#{email}.deleted.%")

      users.each do |user|
        puts "User #{user.email} with id #{user.id} have #{user.persona.provider.claims.count} claims for their provider, \"#{user.persona.provider.name}\""
      end
      puts("No deleted users found for email \"#{email}.deleted.%\"".red) if users.empty?
    end
  end

  # Deactivate an active account!
  #
  # WARNING: this will
  #   - log out any currently logged in user with that email address
  #   - mark the account as inactive
  #   - prevent future login of the account
  #
  def soft_delete
    emails.each do |email|
      user = User.find_by(email: email)

      if user
        user.persona.soft_delete
        puts "Softly deleted #{user.email}!".green
      else
        puts "User with email #{email} not found!".red
      end
    end
  end

  # Reactivate deactivated account
  #
  # This will allow the user to login
  # with existing password.
  #
  def un_soft_delete
    emails.each do |email|
      user = User.find_by('email LIKE ?', "#{email}.deleted.%")

      if user
        user.persona.update(deleted_at: nil)
        user.update!(deleted_at: nil)
        user.update!(email: email)
        puts "Undid soft delete for #{user.email}!".green
      else
        puts "User email \"#{email}.delete.%\" not found!".red
      end
    end
  end

  # Resets password of users
  #
  # This will:
  #  - log the user out
  #  - force them to request a password reset via the app
  #
  # TODO: could send a password reset autumatically
  #
  def change_password
    emails.each do |email|
      user = User.find_by(email: email)

      if user
        pwd = SecureRandom.base64(15)
        user.update!(password: pwd, password_confirmation: pwd)
        puts "Updated password for #{user.email} with id #{user.id}! They will need to reest it to login!".green
      else
        puts "User with email #{email} not found!".red
      end
    end
  end
end
