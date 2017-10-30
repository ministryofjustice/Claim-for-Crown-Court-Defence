require 'chronic'

# https://github.com/ssoroka/scheduler_daemon for help
class DocumentCleanerTask < Scheduler::SchedulerTask
  every '1d', first_at: Chronic.parse('next 4 am')

  def run
    log('Document Cleaner started')
    DocumentCleaner.new.clean!
  rescue StandardError => ex
    log('There was an error: ' + ex.message)
  ensure
    log('Document Cleaner finished')
  end
end
