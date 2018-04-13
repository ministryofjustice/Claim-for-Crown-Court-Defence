class ManagementInformationGenerationJob < ApplicationJob
  queue_as :default

  def perform(*_args)
    Stats::ManagementInformationGenerator.new.run
  end
end
