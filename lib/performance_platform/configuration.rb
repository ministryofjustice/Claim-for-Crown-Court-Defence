# frozen_string_literal: true

module PerformancePlatform
  class Configuration
    attr_accessor :root_url, :service, :group

    def initialize
      @root_url ||= root_url
      @service ||= service
      @group ||= group
    end
  end
end
