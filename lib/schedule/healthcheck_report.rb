module Schedule
  class HealthcheckReport
    include Sidekiq::Job

    CHECK_EMOJI = { true => ':white_check_mark:', false => ':x:' }.freeze
    CHECK_DESCRIPTIONS = {
      database: 'Database connection',
      redis: 'Redis connection',
      sidekiq: 'Sidekiq process running',
      sidekiq_queue: 'No dead or retrying Sidekiq jobs',
      num_claims: 'Number of claims'
    }.freeze

    def perform
      return unless Settings.healthcheck_report_enabled

      health_check = HealthCheck.new
      slack_notifier = SlackNotifier.new('laa-cccd-alerts', formatter: SlackNotifier::Formatter::Generic.new)
      slack_notifier.build_payload(
        icon: ':penguin:',
        title: 'Daily healthcheck',
        message: format_message(health_check.checks),
        status: health_check.healthy? ? :pass : :fail
      )
      slack_notifier.send_message
    end

    private

    def format_message(checks)
      checks.map { |name, value| "#{CHECK_DESCRIPTIONS.fetch(name)}: #{format_value(name, value)}" }.join("\n")
    end

    def format_value(name, value)
      return value if name == :num_claims

      CHECK_EMOJI.fetch(value)
    end
  end
end
