# frozen_string_literal: true

# Utility class for bulk operations on external user account(s).
#
# Needs to be loaded and run in a rails console
# running an instance of the [CCCD application](https://github.com/ministryofjustice/Claim-for-Crown-Court-Defence)
#
# example:
#  accounts = Utils::AccountSetter.new(EMAILS)
#  accounts.report
#  accounts.soft_delete
#  accounts.un_soft_delete
#  accounts.change_password
#

# rubocop:disable Rails/Output
module Utils
  class AccountSetter
    attr_reader :emails

    def initialize(emails)
      @emails = emails
    end

    # Find active or inactve accounts with matching email and
    # report basic information.
    #
    # rubocop:disable Metrics/AbcSize
    def report(format: nil)
      report = []

      emails.each do |email|
        users = User.where(email:)
        users.each { |user| report.append(found_user_template(user)) }
        report.append({ email:, found: false }) if users.empty?

        users = User.where('email LIKE ?', "#{email}.deleted.%")
        users.each { |user| report.append(found_user_template(user)) }
        report.append({ email: "#{email}.deleted.%", found: false }) if users.empty?
      end

      format.eql?('csv') ? csv(report) : report
    end
    # rubocop:enable Metrics/AbcSize

    # Deactivate an active account!
    #
    # WARNING: this will
    #   - log out any currently logged in user with that email address
    #   - mark the account as inactive
    #   - prevent future login of the account
    #
    def soft_delete
      emails.each do |email|
        user = User.find_by(email:)

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
    # rubocop:disable Metrics/MethodLength
    def un_soft_delete
      emails.each do |email|
        user = User.find_by('email LIKE ?', "#{email}.deleted.%")

        if user
          user.persona.update(deleted_at: nil)
          user.update!(deleted_at: nil)
          user.update!(email:)
          puts "Undid soft delete for #{user.email}!".green
        else
          puts "User email \"#{email}.delete.%\" not found!".red
        end
      end
    end
    # rubocop:enable Metrics/MethodLength

    # Disable account(s)
    #
    # WARNING: this will
    #   - log out any currently logged in user with that email address
    #   - mark the account as disabled
    #   - prevent future login of the account
    #
    def disable
      emails.each do |email|
        user = User.find_by(email:)

        if user&.enabled?
          user.disable
          puts "User with email \"#{user.email}\" disabled!".green
        else
          puts "Enabled user with email \"#{email}\" not found!".red
        end
      end
    end

    # Enable disabled account(s)
    #
    # This will allow the user to login
    # with existing password.
    #
    def enable
      emails.each do |email|
        user = User.find_by(email:)

        if user&.disabled?
          user.enable
          puts "User with email \"#{user.email}\" enabled!".green
        else
          puts "Disabled user with email \"#{email}\" not found!".red
        end
      end
    end

    # Resets password of users
    #
    # This will:
    #  - log the user out
    #  - force them to request a password reset via the app
    #
    # TODO: could send a password reset automatically
    #
    def change_password
      emails.each do |email|
        user = User.find_by(email:)

        if user
          pwd = SecureRandom.base64(15)
          user.update!(password: pwd, password_confirmation: pwd)
          puts "Updated password for #{user.email} with id #{user.id}! They will need to reest it to login!".green
        else
          puts "User with email #{email} not found!".red
        end
      end
    end

    private

    def found_user_template(user)
      { email: user.email, found: true, id: user.id,
        active: user.active?, enabled: user.enabled?,
        provider: user.persona.provider.name,
        claims: user.persona.provider.claims.count }
    end

    def csv(report)
      CSV.generate do |csv|
        csv << %i[email found id active enabled provider claims]
        report.each do |item|
          csv << item.values
        end
      end
    end
  end
end
# rubocop:enable Rails/Output
