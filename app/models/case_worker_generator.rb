require 'yaml'


module DemoData

  class CaseWorkerGenerator

    def initialize(count = 2)
      @count = 2
      @data = YAML.file_load(File.dirname(__FILE__) + '/fixtures/caseworkers.yml')
    end

    def run

    end

  end
end