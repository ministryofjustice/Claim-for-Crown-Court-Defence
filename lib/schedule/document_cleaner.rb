module Schedule
  class DocumentCleaner
    include Sidekiq::Job
    include Sentry::Cron::MonitorCheckIns

    sentry_monitor_check_ins slug: '<Schedule::DocumentCleaner>'

    def perform
      logger.info('Document Cleaner started')
      ::DocumentCleaner.new.clean!
    rescue StandardError => e
      logger.error('There was an error: ' + e.message)
    ensure
      logger.info('Document Cleaner finished')
    end
  end
end
