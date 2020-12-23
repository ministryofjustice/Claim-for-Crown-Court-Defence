require 'chronic'

# https://github.com/ssoroka/scheduler_daemon
class PollInjectionResponsesTask < Scheduler::SchedulerTask
  environments :production
  every '1m'

  def run
    queue = Settings.aws.response_queue
    return unless queue
    MessageQueue::AwsClient.new(queue).poll!
  rescue StandardError => e
    log("Error checking queue #{queue || 'nil'} for messages: #{e.message}")
  end
end
