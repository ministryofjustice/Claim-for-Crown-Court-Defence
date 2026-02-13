# https://github.com/ssoroka/scheduler_daemon for help
class DocumentCanaryTask < Scheduler::SchedulerTask
  every '1d', first_at: Chronic.parse('next 3:00 am')

  def run
    return skip_tasks if Rails.env.in? %w[development test]

    Rails.application.load_tasks
    Rake::Task['canary:create_document_canary'].invoke
  end

  private

  def skip_tasks
    Rails.logger.info("#{self.class} only runs in the production environment")
  end
end
