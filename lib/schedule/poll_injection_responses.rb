module Schedule
  class PollInjectionResponses
    include Sidekiq::Job
    include Sentry::Cron::MonitorCheckIns

    sentry_monitor_check_ins slug: `Schedule::PollInjectionResponses`

    def perform
      queue = Settings.aws.response_queue
      return unless queue
      messages = MessageQueue::AwsClient.new(queue).poll!
      logger.info("#{messages.count} injection #{'response'.pluralize(messages.count)} found")
    rescue StandardError => e
      logger.error("Error checking queue #{queue || 'nil'} for messages: #{e.message}")
    end
  end
end
