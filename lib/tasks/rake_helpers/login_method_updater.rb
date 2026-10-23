require 'csv'

module Tasks
  module RakeHelpers
    class LoginMethodUpdater
      Result = Struct.new(:changed, :unchanged, :not_found)

      def initialize(login_method, dry_run: true)
        @login_method = login_method
        @dry_run = dry_run
      end

      # The CSV needs the email address in the first column; an "email" header row is optional.
      # `changed` holds the emails of the users updated (or that would be updated in a dry run).
      def call(csv_path)
        emails = read_emails(csv_path)
        users = User.where('LOWER(email) IN (?)', emails).to_a
        changed = update_routes(users)

        Result.new(changed, users.size - changed.size, emails - users.map { |user| user.email.downcase })
      end

      private

      def update_routes(users)
        routes = LoginRoute.where(id: users.map(&:id)).where.not(login_method: @login_method).to_a
        LoginRoute.transaction { routes.each { |route| route.update!(login_method: @login_method) } } unless @dry_run
        routes.map { |route| users.find { |user| user.id == route.id }.email }
      end

      def read_emails(csv_path)
        CSV.foreach(csv_path).filter_map { |row| row.first&.strip&.downcase.presence }
           .reject { |email| email == 'email' }.uniq
      end
    end
  end
end
