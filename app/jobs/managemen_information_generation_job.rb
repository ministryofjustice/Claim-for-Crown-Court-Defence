class ManagemenInformationGenerationJob < ActiveJob::Base
  queue_as :default

  def perform(*args)
    Stats::ManagementInformationGenerator.new.run
  end
end
