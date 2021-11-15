require 'sidekiq-scheduler'

class DocumentCleanerScheduler
  include Sidekiq::Worker

  def perfrom
    LogStuff.info { "#{self.class.name} started" }
    DocumentCleaner.new.clean!
  rescue StandardError => e
    LogStuff.error { "#{self.class.name} error: " + e.message }
  ensure
    LogStuff.info { "#{self.class.name} finished" }
  end
end
