module Schedule
  class DocumentCleaner
    include Sidekiq::Job
    include Sentry::Cron::MonitorCheckIns

    sentry_monitor_check_ins

    def sentry_monitor_slug(name: self.name)
      @sentry_monitor_slug ||= begin
                                 slug = name.gsub('::', '-').downcase
                                 slug[-MAX_SLUG_LENGTH..-1] || slug
                               end
    end


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
